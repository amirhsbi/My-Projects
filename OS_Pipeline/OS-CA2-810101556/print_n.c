#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s N\n", argv[0]);
        return 1;
    }

    char *endptr = NULL;
    long n = strtol(argv[1], &endptr, 10);
    if (*endptr != '\0' || n < 0) {
        fprintf(stderr, "Invalid number: %s\n", argv[1]);
        return 1;
    }

    for (long i = 0; i < n; ++i) {
        if (i > 0) {
            printf(", ");
        }
        printf("hello");
    }
    printf("\n");

    return 0;
}
