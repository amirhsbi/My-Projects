#include <iostream>
#include <vector>
#include <string>
#include <sstream>
#include <cstring>
#include <cctype>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>

using namespace std;

const char* NAMED_PIPE_PATH = "/tmp/np_fifo";

struct Command {
    vector<string> args;
    bool in_from_named = false;
    bool out_to_named = false;
    bool in_from_file = false;
    bool out_to_file = false;
    string in_file;
    string out_file;
};

vector<string> tokenize(const string &line) {
    vector<string> tokens;
    string cur;
    bool in_quotes = false;

    auto flush = [&]() {
        if (!cur.empty()) {
            tokens.push_back(cur);
            cur.clear();
        }
    };

    for (size_t i = 0; i < line.size(); ++i) {
        char c = line[i];
        if (in_quotes) {
            if (c == '"') {
                in_quotes = false;
                flush();
            } else {
                cur.push_back(c);
            }
        } else {
            if (c == '"') {
                in_quotes = true;
            } else if (isspace((unsigned char)c)) {
                flush();
            } else if (c == '|' || c == '<' || c == '>') {
                flush();
                string t(1, c);
                tokens.push_back(t);
            } else {
                cur.push_back(c);
            }
        }
    }
    flush();
    return tokens;
}

bool parse_commands(const vector<string> &tokens, vector<Command> &commands) {
    commands.clear();
    Command current;
    bool expect_target = false;
    char last_redir = 0;

    if (tokens.empty()) return false;

    for (size_t i = 0; i < tokens.size(); ++i) {
        const string &tok = tokens[i];

        if (expect_target) {
            if (tok == "|" || tok == "<" || tok == ">") {
                cerr << "Error: redirection must be followed by a target.\n";
                return false;
            }
            if (last_redir == '<') {
                if (tok == "np") {
                    current.in_from_named = true;
                } else {
                    current.in_from_file = true;
                    current.in_file = tok;
                }
            } else if (last_redir == '>') {
                if (tok == "np") {
                    current.out_to_named = true;
                } else {
                    current.out_to_file = true;
                    current.out_file = tok;
                }
            }
            expect_target = false;
            last_redir = 0;
        } else if (tok == "|") {
            if (current.args.empty()) {
                cerr << "Error: empty command before or after '|'.\n";
                return false;
            }
            commands.push_back(current);
            current = Command();
        } else if (tok == "<" || tok == ">") {
            expect_target = true;
            last_redir = (tok == "<") ? '<' : '>';
        } else {
            current.args.push_back(tok);
        }
    }

    if (expect_target) {
        cerr << "Error: redirection operator without target.\n";
        return false;
    }

    if (current.args.empty()) {
        cerr << "Error: trailing '|'.\n";
        return false;
    }

    commands.push_back(current);
    return true;
}

void execute_pipeline(vector<Command> &commands) {
    int n = commands.size();
    if (n == 0) return;

    vector<pid_t> pids;
    pids.reserve(n);

    int prev_pipe_read_fd = -1;

    for (int i = 0; i < n; ++i) {
        int pipefd[2];
        bool need_pipe = (i != n - 1);

        if (need_pipe) {
            if (pipe(pipefd) == -1) {
                perror("pipe");
                return;
            }
        }

        pid_t pid = fork();
        if (pid < 0) {
            perror("fork");
            return;
        }

        if (pid == 0) {
            if (commands[i].in_from_named) {
                int fd = open(NAMED_PIPE_PATH, O_RDONLY);
                if (fd == -1) {
                    perror("open named pipe for read");
                    _exit(1);
                }
                if (dup2(fd, STDIN_FILENO) == -1) {
                    perror("dup2 in_from_named");
                    _exit(1);
                }
                close(fd);
            } else if (commands[i].in_from_file) {
                int fd = open(commands[i].in_file.c_str(), O_RDONLY);
                if (fd == -1) {
                    perror("open input file");
                    _exit(1);
                }
                if (dup2(fd, STDIN_FILENO) == -1) {
                    perror("dup2 in_from_file");
                    _exit(1);
                }
                close(fd);
            } else if (prev_pipe_read_fd != -1) {
                if (dup2(prev_pipe_read_fd, STDIN_FILENO) == -1) {
                    perror("dup2 prev_pipe_read_fd");
                    _exit(1);
                }
            }

            if (commands[i].out_to_named) {
                int fd = open(NAMED_PIPE_PATH, O_WRONLY);
                if (fd == -1) {
                    perror("open named pipe for write");
                    _exit(1);
                }
                if (dup2(fd, STDOUT_FILENO) == -1) {
                    perror("dup2 out_to_named");
                    _exit(1);
                }
                close(fd);
            } else if (commands[i].out_to_file) {
                int fd = open(commands[i].out_file.c_str(),
                              O_WRONLY | O_CREAT | O_TRUNC,
                              0666);
                if (fd == -1) {
                    perror("open output file");
                    _exit(1);
                }
                if (dup2(fd, STDOUT_FILENO) == -1) {
                    perror("dup2 out_to_file");
                    _exit(1);
                }
                close(fd);
            } else if (need_pipe) {
                if (dup2(pipefd[1], STDOUT_FILENO) == -1) {
                    perror("dup2 pipe write end");
                    _exit(1);
                }
            }

            if (prev_pipe_read_fd != -1) close(prev_pipe_read_fd);
            if (need_pipe) {
                close(pipefd[0]);
                close(pipefd[1]);
            }

            if (!commands[i].args.empty() &&
                commands[i].args[0].find('/') == string::npos) {
                string local = "./" + commands[i].args[0];
                if (access(local.c_str(), X_OK) == 0) {
                    commands[i].args[0] = local;
                }
            }

            vector<char*> argv;
            for (string &arg : commands[i].args) {
                argv.push_back(const_cast<char*>(arg.c_str()));
            }
            argv.push_back(nullptr);

            execvp(argv[0], argv.data());
            perror("execvp");
            _exit(1);
        } else {
            pids.push_back(pid);

            if (prev_pipe_read_fd != -1) {
                close(prev_pipe_read_fd);
            }

            if (need_pipe) {
                close(pipefd[1]);
                prev_pipe_read_fd = pipefd[0];
            }
        }
    }

    for (pid_t pid : pids) {
        int status;
        waitpid(pid, &status, 0);
    }
}

int main() {
    if (mkfifo(NAMED_PIPE_PATH, 0666) == -1) {
        if (errno != EEXIST) {
            perror("mkfifo");
            cerr << "Failed to create named pipe at " << NAMED_PIPE_PATH << endl;
            return 1;
        }
    }

    int keep_fd = open(NAMED_PIPE_PATH, O_RDWR);
    if (keep_fd == -1) {
        perror("open NAMED_PIPE_PATH O_RDWR");
    }

    string line;
    while (true) {
        cout << "myshell> ";
        if (!getline(cin, line)) {
            break;
        }

        if (line.empty()) continue;

        if (line == "exit") {
            break;
        }

        vector<string> tokens = tokenize(line);
        vector<Command> commands;
        if (!parse_commands(tokens, commands)) {
            continue;
        }

        execute_pipeline(commands);
    }

    if (keep_fd != -1) close(keep_fd);

    return 0;
}
