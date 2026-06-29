#include <stdio.h>
#include <ctype.h>

int main(int argc, char *argv[]) {
    long count = 0;
    if (argc > 1) {
        for (int i = 1; i < argc; ++i) {
            for (int j = 0; argv[i][j] != '\0'; ++j) {
                unsigned char c = argv[i][j];
                if (isalpha(c)) count++;
            }
        }
    } else {
        int ch;
        while ((ch = getchar()) != EOF) {
            unsigned char c = ch;
            if (isalpha(c)) count++;
            if (c == '\n') break;
        }
    }
    printf("%ld\n", count);
    return 0;
}
