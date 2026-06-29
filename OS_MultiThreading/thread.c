#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>
#include <time.h>

int N;

void* print_message(void* arg) {
    int id = *(int*)arg;
    int sleep_time = rand() % 4;
    sleep(sleep_time);
    printf("I'm thread %d of %d\n", id, N);
    free(arg);
    return NULL;
}

int main() {
    srand(time(NULL));
    printf("Enter number of threads (N): ");
    scanf("%d", &N);

    pthread_t threads[N];

    for (int i = 0; i < N; i++) {
        int* id = malloc(sizeof(int));
        *id = i;
        pthread_create(&threads[i], NULL, print_message, id);
    }

    for (int i = 0; i < N; i++) {
        pthread_join(threads[i], NULL);
    }

    return 0;
}