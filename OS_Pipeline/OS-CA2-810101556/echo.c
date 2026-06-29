#include <stdio.h>

int main(int argc, char *argv[]) {
    if (argc > 1) {
        for (int i = 1; i < argc; ++i) {
            if (i > 1) {
                putchar(' ');
            }
            fputs(argv[i], stdout);
        }
        putchar('\n');
    } else {
        int c;
        while ((c = getchar()) != EOF) {
            putchar(c);
            if (c == '\n') {
                break;
            }
        }
    }

    return 0;
}
