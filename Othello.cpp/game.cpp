#include "game.hpp"
#include <fstream>
#include <sstream>
#include <cctype>

using namespace std;

namespace {
    int scoreOf(const Board& b, char color) {
        return b.count(color);
    }
}

Game::Game() {
    newGame();
}

void Game::run() {
    string command;
    cout << "Welcome to Othello\n";
    while (true) {
        if (!(cin >> command)) {
            if (cin.eof()) {
                break;
            }
            cin.clear();
            string dummy;
            getline(cin, dummy);
            continue;
        }
        if (command == "new") {
            newGame();
        } else if (command == "place") {
            place();
        } else if (command == "undo") {
            undo();
        } else if (command == "redo") {
            redo();
        } else if (command == "save") {
            save();
        } else if (command == "load") {
            load();
        } else if (command == "exit") {
            break;
        } else {
            invalid();
        }
    }
}

void Game::newGame() {
    board.reset();
    turn = 'B';
    history.clear();
    redoStack.clear();
    pushHistory();
    printState();
}

void Game::pushHistory() {
    history.push_back({ board.grid(), turn });
}

void Game::setState(const State& s) {
    board.grid() = s.grid;
    turn = s.turn;
}

bool Game::hasAnyMove(char color) const {
    return !board.validMoves(color).empty();
}

void Game::maybeAutoPass() {
    if (!hasAnyMove(turn)) {
        char other = turn == 'B' ? 'W' : 'B';
        if (hasAnyMove(other)) {
            cout << "No valid moves for " << (turn == 'B' ? "Black" : "White") << ". Turn passes.\n";
            turn = other;
        }
    }
}

void Game::endIfFinished() {
    if (!hasAnyMove('B') && !hasAnyMove('W')) {
        printState();
        int b = scoreOf(board, 'B');
        int w = scoreOf(board, 'W');
        string winner;
        if (b > w) {
            winner = "Black";
        } else if (w > b) {
            winner = "White";
        } else {
            winner = "Draw";
        }
        cout << "Winner: " << winner << "\n";
    }
}

bool Game::parseCoordToken(const string& token, int& r, int& c) {
    if (token.size() < 2) {
        return false;
    }
    char col = token[0];
    if (!isalpha((unsigned char)col)) {
        return false;
    }
    string digits = token.substr(1);
    if (digits.empty()) {
        return false;
    }
    for (char d : digits) {
        if (!isdigit((unsigned char)d)) {
            return false;
        }
    }
    col = (char)toupper((unsigned char)col);
    int rowNum = 0;
    try {
        rowNum = stoi(digits);
    } catch (...) {
        return false;
    }
    c = col - 'A';
    r = rowNum - 1;
    if (r < 0 || r >= SIZE || c < 0 || c >= SIZE) {
        return false;
    }
    return true;
}

void Game::place() {
    string coord;
    if (!(cin >> coord)) {
        cout << "Invalid input\n";
        return;
    }
    int r = -1;
    int c = -1;
    if (!parseCoordToken(coord, r, c)) {
        cout << "Invalid position\n";
        return;
    }
    if (!board.isValidMove(turn, r, c)) {
        cout << "Illegal move\n";
        printState();
        return;
    }
    redoStack.clear();
    board.applyMove(turn, r, c);
    turn = turn == 'B' ? 'W' : 'B';
    pushHistory();
    maybeAutoPass();
    printState();
    endIfFinished();
}

void Game::undo() {
    if (history.size() <= 1) {
        cout << "Nothing to undo\n";
        printState();
        return;
    }
    redoStack.push_back(history.back());
    history.pop_back();
    setState(history.back());
    printState();
}

void Game::redo() {
    if (redoStack.empty()) {
        cout << "Nothing to redo\n";
        printState();
        return;
    }
    State s = redoStack.back();
    redoStack.pop_back();
    setState(s);
    history.push_back(s);
    printState();
}

void Game::printState(ostream& out) const {
    board.print(out);
    out << "Player Turn: " << turn << "\n";
    out << "Score - B: " << scoreOf(board, 'B') << " | W: " << scoreOf(board, 'W') << "\n";
}

void Game::save() {
    string filename;
    if (!(cin >> filename)) {
        cout << "Invalid filename\n";
        return;
    }
    if (filename.size() < 4 || filename.substr(filename.size() - 4) != ".oth") {
        filename += ".oth";
    }
    ofstream f(filename);
    if (!f) {
        cout << "Error saving file\n";
        return;
    }
    printState(f);
    cout << "Game saved to " << filename << "\n";
}

void Game::load() {
    string filename;
    if (!(cin >> filename)) {
        cout << "Invalid filename\n";
        return;
    }
    ifstream f(filename);
    if (!f) {
        cout << "File not found\n";
        return;
    }
    string header;
    getline(f, header);
    if (header.rfind("  A B C D E F G H", 0) != 0) {
        cout << "Invalid file\n";
        return;
    }
    Board::Grid ng{};
    for (int i = 0; i < SIZE; ++i) {
        string line;
        getline(f, line);
        istringstream iss(line);
        string tok;
        if (!(iss >> tok)) {
            cout << "Invalid file\n";
            return;
        }
        for (int j = 0; j < SIZE; ++j) {
            if (!(iss >> tok) || tok.size() != 1) {
                cout << "Invalid file\n";
                return;
            }
            char ch = tok[0];
            if (ch != '.' && ch != 'B' && ch != 'W') {
                cout << "Invalid file\n";
                return;
            }
            ng[i][j] = ch;
        }
    }
    string turnLine;
    getline(f, turnLine);
    char t = 'B';
    for (int i = (int)turnLine.size() - 1; i >= 0; --i) {
        if (turnLine[i] == 'B' || turnLine[i] == 'W') {
            t = turnLine[i];
            break;
        }
    }
    board.grid() = ng;
    turn = t;
    history.clear();
    redoStack.clear();
    pushHistory();
    printState();
}

void Game::invalid() {
    cout << "Invalid command\n";
}
