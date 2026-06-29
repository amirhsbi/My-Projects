#ifndef BOARD_HPP
#define BOARD_HPP

#include <array>
#include <vector>
#include <iostream>

using namespace std;

constexpr int SIZE = 8;

class Board {
public:
    using Grid = array<array<char, SIZE>, SIZE>;

    Board();

    void reset();
    bool inBounds(int r, int c) const;
    char at(int r, int c) const;
    void set(int r, int c, char v);
    void print(ostream& out = cout) const;
    int count(char color) const;
    bool isValidMove(char color, int r, int c) const;
    bool applyMove(char color, int r, int c);
    vector<pair<int, int>> validMoves(char color) const;

    const Grid& grid() const { return grid_; }
    Grid& grid() { return grid_; }

private:
    Grid grid_;
    bool wouldFlipInDir(char color, int r, int c, int dr, int dc) const;
    int flipInDir(char color, int r, int c, int dr, int dc);
};

#endif
