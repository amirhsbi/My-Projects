# HW1 - Part 2: Goroutine Scheduling and Performance Experiment

## Overview

This part studies how increasing concurrency affects execution time, throughput, and latency in Go programs.

The program varies:

- Number of goroutines
- Workload type
- `GOMAXPROCS`

The goal is not to directly implement operating-system-level context switching. Instead, the goal is to observe the effects of Go scheduler behavior, CPU contention, and synchronization overhead.

## Files

    part2/
    ├── main.go
    ├── chart.go
    ├── benchmark
    ├── README.md
    └── results/
        ├── results.csv
        ├── run-output.txt
        ├── smoke.csv
        ├── throughput.svg
        └── latency.svg

## Requirements

- Go 1.22+
- Linux
- No external Go libraries

Only Go standard-library packages are used.

## Workloads

### CPU-bound workload

Each goroutine repeatedly performs numeric computation. This workload mainly stresses CPU execution and makes the effect of `GOMAXPROCS` visible.

### Mixed workload

Each goroutine performs a smaller amount of computation and then enters a shared critical section protected by a mutex. This workload demonstrates the effect of synchronization and scheduler overhead.

## Experiment Matrix

The required goroutine counts are:

    1, 2, 4, 8, 16, 32, 64

The tested `GOMAXPROCS` values are:

    1, 2, runtime.NumCPU(), and 4

On the test VM, `runtime.NumCPU()` was 2. Since this duplicates the required value `2`, an extra oversubscription case `GOMAXPROCS=4` was added.

## Metrics

The program reports the following metrics for each configuration:

- Workload type
- `GOMAXPROCS`
- Number of goroutines
- Jobs per worker
- Total jobs
- Total execution time in milliseconds
- Throughput in jobs per second
- Average latency per job in microseconds
- Minimum latency
- Maximum latency
- Standard deviation of latency

## Build

From the `HW1` root directory:

    go build -o part2/benchmark part2/main.go

## Smoke Test

    ./part2/benchmark -jobs 50 -out part2/results/smoke.csv

## Full Benchmark

    ./part2/benchmark -jobs 500 -out part2/results/results.csv | tee part2/results/run-output.txt

## Generate Charts

    go run part2/chart.go part2/results/results.csv

This creates:

    part2/results/throughput.svg
    part2/results/latency.svg

## Notes on Results

On the 2-vCPU VM, CPU-bound throughput improved significantly when moving from `GOMAXPROCS=1` to `GOMAXPROCS=2`. Increasing to `GOMAXPROCS=4` did not provide a proportional improvement because the VM still only had two CPU cores.

For the mixed workload, throughput was often higher than the CPU-bound workload because each job had less computation, but latency increased as goroutine count increased due to mutex contention and scheduling overhead.
