#include "board.hpp"
using namespace std;

namespace {
    const array<pair<int, int>, 8> DIRS = {{
        {-1, -1}, {-1, 0}, {-1, 1},
        { 0, -1},          { 0, 1},
        { 1, -1}, { 1, 0}, { 1, 1}
    }};
}

Board::Board() {
    reset();
}
void Board::reset() {
    for (auto& row : grid_) {
        row.fill('.');
    }
    grid_[3][3] = 'W';
    grid_[3][4] = 'B';
    grid_[4][3] = 'B';
    grid_[4][4] = 'W';
}

bool Board::inBounds(int r, int c) const {
    return r >= 0 && r < SIZE && c >= 0 && c < SIZE;
}

char Board::at(int r, int c) const {
    return grid_[r][c];
}

void Board::set(int r, int c, char v) {
    grid_[r][c] = v;
}

void Board::print(ostream& out) const {
    out << "  A B C D E F G H\n";
    for (int i = 0; i < SIZE; ++i) {
        out << i + 1 << " ";
        for (int j = 0; j < SIZE; ++j) {
            out << grid_[i][j];
            if (j != SIZE - 1) {
                out << " ";
            }
        }
        out << "\n";
    }
}

int Board::count(char color) const {
    int s = 0;
    for (int r = 0; r < SIZE; ++r) {
        for (int c = 0; c < SIZE; ++c) {
            if (grid_[r][c] == color) {
                ++s;
            }
        }
    }
    return s;
}

bool Board::wouldFlipInDir(char color, int r, int c, int dr, int dc) const {
    char opp = color == 'B' ? 'W' : 'B';
    int i = r + dr;
    int j = c + dc;
    bool seen = false;
    while (inBounds(i, j) && at(i, j) == opp) {
        seen = true;
        i += dr;
        j += dc;
    }
    if (!seen) {
        return false;
    }
    if (!inBounds(i, j)) {
        return false;
    }
    return at(i, j) == color;
}

bool Board::isValidMove(char color, int r, int c) const {
    if (!inBounds(r, c)) {
        return false;
    }
    if (at(r, c) != '.') {
        return false;
    }
    for (auto d : DIRS) {
        if (wouldFlipInDir(color, r, c, d.first, d.second)) {
            return true;
        }
    }
    return false;
}

int Board::flipInDir(char color, int r, int c, int dr, int dc) {
    if (!wouldFlipInDir(color, r, c, dr, dc)) {
        return 0;
    }
    char opp = color == 'B' ? 'W' : 'B';
    int i = r + dr;
    int j = c + dc;
    int flipped = 0;
    while (inBounds(i, j) && at(i, j) == opp) {
        set(i, j, color);
        ++flipped;
        i += dr;
        j += dc;
    }
    return flipped;
}

bool Board::applyMove(char color, int r, int c) {
    if (!isValidMove(color, r, c)) {
        return false;
    }
    set(r, c, color);
    for (auto d : DIRS) {
        flipInDir(color, r, c, d.first, d.second);
    }
    return true;
}

vector<pair<int, int>> Board::validMoves(char color) const {
    vector<pair<int, int>> v;
    for (int r = 0; r < SIZE; ++r) {
        for (int c = 0; c < SIZE; ++c) {
            if (isValidMove(color, r, c)) {
                v.push_back({ r, c });
            }
        }
    }
    return v;
}
