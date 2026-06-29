#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>

#define ARR_SIZE 10000000

int *array;
long long total_sum = 0;
int num_threads;

typedef struct {
    int start_index;
    int end_index;
    long long partial_sum;
} ThreadData;

void* thread_sum(void* arg) {
    ThreadData* data = (ThreadData*)arg;
    data->partial_sum = 0;
    for (int i = data->start_index; i < data->end_index; i++) {
        data->partial_sum += array[i];
    }
    return NULL;
}

double get_time_diff(struct timespec start, struct timespec end) {
    return (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / 1e9;
}

int main() {
    srand(time(NULL));
    array = malloc(ARR_SIZE * sizeof(int));
    for (int i = 0; i < ARR_SIZE; i++) {
        array[i] = rand() % 100;
    }

    struct timespec start, end;
    long long single_sum = 0;

    clock_gettime(CLOCK_MONOTONIC, &start);
    for (int i = 0; i < ARR_SIZE; i++) {
        single_sum += array[i];
    }
    clock_gettime(CLOCK_MONOTONIC, &end);
    printf("Single-thread Time: %f sec, Sum: %lld\n", get_time_diff(start, end), single_sum);

    printf("Enter number of threads (T): ");
    scanf("%d", &num_threads);

    pthread_t threads[num_threads];
    ThreadData thread_data[num_threads];
    int chunk_size = ARR_SIZE / num_threads;

    clock_gettime(CLOCK_MONOTONIC, &start);
    for (int i = 0; i < num_threads; i++) {
        thread_data[i].start_index = i * chunk_size;
        thread_data[i].end_index = (i == num_threads - 1) ? ARR_SIZE : (i + 1) * chunk_size;
        pthread_create(&threads[i], NULL, thread_sum, &thread_data[i]);
    }

    long long multi_sum = 0;
    for (int i = 0; i < num_threads; i++) {
        pthread_join(threads[i], NULL);
        multi_sum += thread_data[i].partial_sum;
    }
    clock_gettime(CLOCK_MONOTONIC, &end);

    printf("Multi-thread Time: %f sec, Sum: %lld\n", get_time_diff(start, end), multi_sum);

    free(array);
    return 0;
}