#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

#define NUM_RUNS 10
#define M 20
#define K 100000

long counter = 0;

void* worker(void* arg) {
    for (int i = 0; i < K; i++) {
        counter++;
    }
    pthread_exit(NULL);
}

int main() {
    printf("--- Without Mutex (Unsafe) ---\n");
    printf("| Run # | Final Counter |\n");
    printf("|-------|---------------|\n");

    for (int run = 1; run <= NUM_RUNS; run++) {
        counter = 0;
        pthread_t threads[M];

        for (int i = 0; i < M; i++) {
            pthread_create(&threads[i], NULL, worker, NULL);
        }

        for (int i = 0; i < M; i++) {
            pthread_join(threads[i], NULL);
        }

        printf("| %-5d | %-13ld |\n", run, counter);
    }
    printf("-------------------------\n");
    return 0;
}