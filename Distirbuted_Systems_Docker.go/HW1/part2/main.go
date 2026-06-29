package main

import (
	"encoding/csv"
	"flag"
	"fmt"
	"math"
	"os"
	"runtime"
	"sort"
	"strconv"
	"sync"
	"time"
)

type Result struct {
	Workload       string
	GOMAXPROCS     int
	Goroutines     int
	JobsPerWorker  int
	TotalJobs      int
	TotalTimeMS    float64
	Throughput     float64
	AvgLatencyUS   float64
	MinLatencyUS   float64
	MaxLatencyUS   float64
	StddevLatencyUS float64
}

func main() {
	outPath := flag.String("out", "part2/results/results.csv", "output CSV path")
	jobsPerWorker := flag.Int("jobs", 2000, "number of jobs per goroutine")
	flag.Parse()

	if err := os.MkdirAll("part2/results", 0755); err != nil {
		fmt.Fprintf(os.Stderr, "failed to create results directory: %v\n", err)
		os.Exit(1)
	}

	goroutineCounts := []int{1, 2, 4, 8, 16, 32, 64}
	gomaxprocsValues := gomaxprocsSettings()
	workloads := []string{"cpu", "mixed"}

	var results []Result

	fmt.Printf("NumCPU=%d\n", runtime.NumCPU())
	fmt.Printf("JobsPerWorker=%d\n", *jobsPerWorker)

	for _, workload := range workloads {
		for _, gomax := range gomaxprocsValues {
			for _, goroutines := range goroutineCounts {
				result := runExperiment(workload, gomax, goroutines, *jobsPerWorker)
				results = append(results, result)

				fmt.Printf(
					"workload=%s gomaxprocs=%d goroutines=%d total_ms=%.2f throughput=%.2f avg_latency_us=%.2f\n",
					result.Workload,
					result.GOMAXPROCS,
					result.Goroutines,
					result.TotalTimeMS,
					result.Throughput,
					result.AvgLatencyUS,
				)
			}
		}
	}

	if err := writeCSV(*outPath, results); err != nil {
		fmt.Fprintf(os.Stderr, "failed to write CSV: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("wrote results to %s\n", *outPath)
}

func runExperiment(workload string, gomaxprocs int, goroutines int, jobsPerWorker int) Result {
	runtime.GOMAXPROCS(gomaxprocs)

	totalJobs := goroutines * jobsPerWorker
	latencies := make([]float64, 0, totalJobs)

	var latMu sync.Mutex
	var sharedMu sync.Mutex
	var wg sync.WaitGroup

	start := time.Now()

	for g := 0; g < goroutines; g++ {
		wg.Add(1)

		go func(workerID int) {
			defer wg.Done()

			localLatencies := make([]float64, 0, jobsPerWorker)

			for j := 0; j < jobsPerWorker; j++ {
				jobStart := time.Now()

				switch workload {
				case "cpu":
					_ = cpuWork(workerID, j, 8000)
				case "mixed":
					_ = cpuWork(workerID, j, 1500)
					sharedMu.Lock()
					_ = cpuWork(workerID, j, 300)
					sharedMu.Unlock()
				default:
					panic("unknown workload")
				}

				localLatencies = append(localLatencies, float64(time.Since(jobStart).Microseconds()))
			}

			latMu.Lock()
			latencies = append(latencies, localLatencies...)
			latMu.Unlock()
		}(g)
	}

	wg.Wait()
	totalDuration := time.Since(start)

	sort.Float64s(latencies)

	totalTimeSeconds := totalDuration.Seconds()
	totalTimeMS := float64(totalDuration.Microseconds()) / 1000.0
	throughput := float64(totalJobs) / totalTimeSeconds

	avg := average(latencies)
	stddev := stddev(latencies, avg)

	return Result{
		Workload:        workload,
		GOMAXPROCS:      gomaxprocs,
		Goroutines:      goroutines,
		JobsPerWorker:   jobsPerWorker,
		TotalJobs:       totalJobs,
		TotalTimeMS:     totalTimeMS,
		Throughput:      throughput,
		AvgLatencyUS:    avg,
		MinLatencyUS:    latencies[0],
		MaxLatencyUS:    latencies[len(latencies)-1],
		StddevLatencyUS: stddev,
	}
}

func cpuWork(workerID int, jobID int, iterations int) float64 {
	x := float64(workerID + jobID + 1)

	for i := 0; i < iterations; i++ {
		x += math.Sqrt(float64(i)+x) / 3.14159
		x = math.Mod(x*1.000001+7.0, 100000.0)
	}

	return x
}

func average(values []float64) float64 {
	if len(values) == 0 {
		return 0
	}

	var sum float64
	for _, v := range values {
		sum += v
	}

	return sum / float64(len(values))
}

func stddev(values []float64, avg float64) float64 {
	if len(values) == 0 {
		return 0
	}

	var sum float64
	for _, v := range values {
		d := v - avg
		sum += d * d
	}

	return math.Sqrt(sum / float64(len(values)))
}

func uniqueInts(values []int) []int {
	seen := make(map[int]bool)
	var result []int

	for _, value := range values {
		if !seen[value] {
			seen[value] = true
			result = append(result, value)
		}
	}

	sort.Ints(result)
	return result
}

func gomaxprocsSettings() []int {
	values := []int{1, 2, runtime.NumCPU()}

	if runtime.NumCPU() == 2 {
		values = append(values, 4)
	}

	return uniqueInts(values)
}

func writeCSV(path string, results []Result) error {
	file, err := os.Create(path)
	if err != nil {
		return err
	}
	defer file.Close()

	writer := csv.NewWriter(file)
	defer writer.Flush()

	header := []string{
		"workload",
		"gomaxprocs",
		"goroutines",
		"jobs_per_worker",
		"total_jobs",
		"total_time_ms",
		"throughput_jobs_per_sec",
		"avg_latency_us",
		"min_latency_us",
		"max_latency_us",
		"stddev_latency_us",
	}

	if err := writer.Write(header); err != nil {
		return err
	}

	for _, r := range results {
		row := []string{
			r.Workload,
			strconv.Itoa(r.GOMAXPROCS),
			strconv.Itoa(r.Goroutines),
			strconv.Itoa(r.JobsPerWorker),
			strconv.Itoa(r.TotalJobs),
			fmt.Sprintf("%.3f", r.TotalTimeMS),
			fmt.Sprintf("%.3f", r.Throughput),
			fmt.Sprintf("%.3f", r.AvgLatencyUS),
			fmt.Sprintf("%.3f", r.MinLatencyUS),
			fmt.Sprintf("%.3f", r.MaxLatencyUS),
			fmt.Sprintf("%.3f", r.StddevLatencyUS),
		}

		if err := writer.Write(row); err != nil {
			return err
		}
	}

	return writer.Error()
}
