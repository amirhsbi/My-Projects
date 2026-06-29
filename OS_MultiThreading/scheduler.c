#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>

typedef struct {
    char name[4];
    int arrival;
    int burst;
    int start_time;
    int finish_time;
    int waiting_time;
    int turnaround_time;
    int remaining_time;
} Process;

void reset_processes(Process p[], int n, Process src[]) {
    for(int i=0; i<n; i++) {
        p[i] = src[i];
        p[i].remaining_time = p[i].burst;
    }
}

void print_metrics(Process p[], int n, char* alg) {
    double total_wait = 0, total_turn = 0;
    printf("\n--- %s Results ---\n", alg);
    printf("P\tArr\tBurst\tWait\tTurn\n");
    for(int i=0; i<n; i++) {
        printf("%s\t%d\t%d\t%d\t%d\n", p[i].name, p[i].arrival, p[i].burst, p[i].waiting_time, p[i].turnaround_time);
        total_wait += p[i].waiting_time;
        total_turn += p[i].turnaround_time;
    }
    printf("Avg Waiting: %.2f\n", total_wait / n);
    printf("Avg Turnaround: %.2f\n", total_turn / n);
}

void FCFS(Process p[], int n) {
    int current_time = 0;
    for (int i = 0; i < n; i++) {
        if (current_time < p[i].arrival)
            current_time = p[i].arrival;
        
        p[i].start_time = current_time;
        p[i].finish_time = p[i].start_time + p[i].burst;
        p[i].turnaround_time = p[i].finish_time - p[i].arrival;
        p[i].waiting_time = p[i].start_time - p[i].arrival;
        current_time = p[i].finish_time;
        
        printf("| %s (%d-%d) ", p[i].name, p[i].start_time, p[i].finish_time);
    }
    printf("|\n");
}

void SJF(Process p[], int n) {
    int current_time = 0, completed = 0;
    int is_completed[100] = {0};
    
    printf("|");
    while (completed != n) {
        int idx = -1;
        int min_burst = INT_MAX;

        for (int i = 0; i < n; i++) {
            if (p[i].arrival <= current_time && !is_completed[i]) {
                if (p[i].burst < min_burst) {
                    min_burst = p[i].burst;
                    idx = i;
                }
            }
        }

        if (idx != -1) {
            p[idx].start_time = current_time;
            p[idx].finish_time = p[idx].start_time + p[idx].burst;
            p[idx].turnaround_time = p[idx].finish_time - p[idx].arrival;
            p[idx].waiting_time = p[idx].start_time - p[idx].arrival;
            
            printf(" %s (%d-%d) |", p[idx].name, current_time, p[idx].finish_time);
            
            current_time = p[idx].finish_time;
            is_completed[idx] = 1;
            completed++;
        } else {
            current_time++;
        }
    }
    printf("\n");
}

void RR(Process p[], int n, int quantum) {
    int current_time = 0;
    int completed = 0;
    int queue[1000], front = 0, rear = 0;
    int in_queue[100] = {0};

    for(int i=0; i<n; i++) {
        if(p[i].arrival == 0) {
            queue[rear++] = i;
            in_queue[i] = 1;
        }
    }

    printf("|");
    while(completed != n) {
        if (front == rear) { 
            current_time++;
            for(int i=0; i<n; i++) {
                if(p[i].arrival == current_time && !in_queue[i]) {
                    queue[rear++] = i;
                    in_queue[i] = 1;
                }
            }
            continue;
        }

        int idx = queue[front++];
        int exec_time = (p[idx].remaining_time > quantum) ? quantum : p[idx].remaining_time;
        
        printf(" %s (%d-%d) |", p[idx].name, current_time, current_time + exec_time);
        
        p[idx].remaining_time -= exec_time;
        current_time += exec_time;

        for(int i=0; i<n; i++) {
            if(p[i].arrival <= current_time && p[i].remaining_time > 0 && !in_queue[i]) {
                queue[rear++] = i;
                in_queue[i] = 1;
            }
        }

        if(p[idx].remaining_time == 0) {
            p[idx].finish_time = current_time;
            p[idx].turnaround_time = p[idx].finish_time - p[idx].arrival;
            p[idx].waiting_time = p[idx].turnaround_time - p[idx].burst;
            completed++;
        } else {
            queue[rear++] = idx;
        }
    }
    printf("\n");
}

int main() {
    Process s1[] = { {"P1",0,8}, {"P2",0,4}, {"P3",0,1}, {"P4",0,3} };
    int n1 = 4;
    
    Process s2[] = { {"P1",0,7}, {"P2",2,4}, {"P3",4,1}, {"P4",5,4} };
    int n2 = 4;

    Process s3[] = { {"P1",0,20}, {"P2",0,3}, {"P3",0,3} };
    int n3 = 3;

    Process buffer[10];

    printf("=== SCENARIO 1 ===\n");
    reset_processes(buffer, n1, s1); FCFS(buffer, n1); print_metrics(buffer, n1, "FCFS");
    reset_processes(buffer, n1, s1); SJF(buffer, n1); print_metrics(buffer, n1, "SJF");
    reset_processes(buffer, n1, s1); RR(buffer, n1, 4); print_metrics(buffer, n1, "RR (Q=4)");

    printf("\n\n=== SCENARIO 2 ===\n");
    reset_processes(buffer, n2, s2); FCFS(buffer, n2); print_metrics(buffer, n2, "FCFS");
    reset_processes(buffer, n2, s2); SJF(buffer, n2); print_metrics(buffer, n2, "SJF");
    reset_processes(buffer, n2, s2); RR(buffer, n2, 4); print_metrics(buffer, n2, "RR (Q=4)");

    
    printf("\n\n=== SCENARIO 3 ===\n");
    reset_processes(buffer, n3, s3); FCFS(buffer, n3); print_metrics(buffer, n3, "FCFS");
    reset_processes(buffer, n3, s3); SJF(buffer, n3); print_metrics(buffer, n3, "SJF");
    reset_processes(buffer, n3, s3); RR(buffer, n3, 4); print_metrics(buffer, n3, "RR (Q=4)");

    return 0;
}