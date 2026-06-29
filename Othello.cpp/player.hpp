#ifndef PLAYER_HPP
#define PLAYER_HPP

#include <string>

using namespace std;

class Player {
public:
    explicit Player(char c, string n = "") : color(c), name(n) {}
    char color;
    string name;
};

#endif
