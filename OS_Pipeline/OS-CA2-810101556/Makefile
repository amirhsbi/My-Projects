CXX = g++
CC  = gcc
CXXFLAGS = -Wall -Wextra -O2
CFLAGS   = -Wall -Wextra -O2

all: shell echo print_n len

shell: shell.cpp
	$(CXX) $(CXXFLAGS) shell.cpp -o shell

echo: echo.c
	$(CC) $(CFLAGS) echo.c -o echo

print_n: print_n.c
	$(CC) $(CFLAGS) print_n.c -o print_n

len: len.c
	$(CC) $(CFLAGS) len.c -o len

clean:
	rm -f shell echo print_n len
