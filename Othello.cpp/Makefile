CXX = g++
CXXFLAGS = -std=c++20 -O2 -Wall -Wextra -pedantic
LDFLAGS =

SRC = main.cpp board.cpp game.cpp player.cpp
OBJ = $(SRC:.cpp=.o)
TARGET = othello

all: $(TARGET)

$(TARGET): $(OBJ)
	$(CXX) $(CXXFLAGS) -o $@ $^ $(LDFLAGS)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

clean:
	rm -f $(OBJ) $(TARGET)

.PHONY: all clean
