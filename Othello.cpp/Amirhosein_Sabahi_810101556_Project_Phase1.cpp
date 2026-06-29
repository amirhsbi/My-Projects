g++ -std=c++20 -O2 -Wall -Wextra -pedantic main.cpp board.cpp game.cpp player.cpp -o othello.exe

#include <iostream>
#include <vector>
#include <sstream>
#include <fstream>
using namespace std;

const int SIZE = 8;

class Board {
public:
    vector<vector<char>> grid;
    Board() { reset(); }

    void reset() {
        grid.assign(SIZE, vector<char>(SIZE, '.'));
        grid[3][3] = 'W'; grid[3][4] = 'B';
        grid[4][3] = 'B'; grid[4][4] = 'W';
    }

    void print(ostream& out = cout) {
        out << "  A B C D E F G H\n";
        for (int i = 0; i < SIZE; ++i) {
            out << i + 1 << " ";
            for (int j = 0; j < SIZE; ++j)
                out << grid[i][j] << " ";
            out << "\n";
        }
    }
};

class Player {
public:
    char color;
    Player(char c) : color(c) {}
};

class Game {
    Board board;
    char turn = 'B';

public:
    void run() {
        string command;
        cout << "Welcome to Othello\n";
        while (true) {
            cin >> command;
            if (command == "new") newGame();
            else if (command == "place") place();
            else if (command == "save") save();
            else if (command == "load") load();
            else if (command == "exit") break;
            else invalid();
        }
    }

    void newGame() {
        board.reset();
        turn = 'B';
        board.print();
        cout << "Player Turn: " << turn << "\n";
    }

    void place() {
        char y; int x;
        cin >> y >> x;
        int row = x - 1;
        int col = y - 'A';
        if (x < 1 || x > 8 || col < 0 || col >= 8) {
            cout << "Invalid position!\n";
            return;
        }
        if (board.grid[row][col] != '.') {
            cout << "Cell is full!\n";
            return;
        }
        board.grid[row][col] = turn;
        turn = (turn == 'B') ? 'W' : 'B';
        board.print();
        cout << "Player Turn: " << turn << "\n";
    }

    void save() {
        string filename;
        cin >> filename;
        ofstream file(filename);
        if (!file) { cout << "Error saving file.\n"; return; }
        board.print(file);
        file << "Player Turn: " << turn << "\n";
        cout << "Game saved.\n";
    }

    void load() {
        string filename;
        cin >> filename;
        ifstream file(filename);
        if (!file) { cout << "File not found.\n"; return;
        }
        string line;
        getline(file, line); // header
        vector<vector<char>> newGrid;
        for (int i = 0; i < SIZE; ++i) {
            getline(file, line);
            vector<char> row;
            for (int j = 2; j < line.length(); j += 2) {
                row.push_back(line[j]);
            }
            newGrid.push_back(row);
        }
        board.grid = newGrid;
        getline(file, line); 
        if (line.size() >= 15)
            turn = line.back();
        board.print();
        cout << "Player Turn: " << turn << "\n";
    }

    void invalid() {
        cout << "Invalid command!\n";
    }
};

int main() {
    Game game;
    game.run();
    return 0;
}
