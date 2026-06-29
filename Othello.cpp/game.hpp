#ifndef GAME_HPP
#define GAME_HPP

#include "board.hpp"
#include "player.hpp"
#include <vector>
#include <string>
#include <iostream>

using namespace std;

class Game {
public:
    Game();
    void run();

private:
    Board board;
    Player black{ 'B', "Black" };
    Player white{ 'W', "White" };
    char turn = 'B';

    struct State {
        Board::Grid grid;
        char turn;
    };

    vector<State> history;
    vector<State> redoStack;

    void newGame();
    void place();
    void undo();
    void redo();
    void save();
    void load();
    void printState(ostream& out = cout) const;
    void invalid();
    void pushHistory();
    void setState(const State& s);
    bool hasAnyMove(char color) const;
    void maybeAutoPass();
    void endIfFinished();
    static bool parseCoordToken(const string& token, int& r, int& c);
};

#endif
