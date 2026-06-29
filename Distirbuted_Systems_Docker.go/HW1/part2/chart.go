package main

import (
	"encoding/csv"
	"fmt"
	"math"
	"os"
	"sort"
	"strconv"
)

type Row struct {
	Workload     string
	GOMAXPROCS   int
	Goroutines   int
	Throughput   float64
	AvgLatencyUS float64
}

func main() {
	if len(os.Args) != 2 {
		fmt.Fprintf(os.Stderr, "usage: %s <results.csv>\n", os.Args[0])
		os.Exit(1)
	}

	rows, err := readRows(os.Args[1])
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to read rows: %v\n", err)
		os.Exit(1)
	}

	if err := writeChart("part2/results/throughput.svg", rows, "throughput", "Throughput (jobs/sec)"); err != nil {
		fmt.Fprintf(os.Stderr, "failed to write throughput chart: %v\n", err)
		os.Exit(1)
	}

	if err := writeChart("part2/results/latency.svg", rows, "latency", "Average Latency (microseconds)"); err != nil {
		fmt.Fprintf(os.Stderr, "failed to write latency chart: %v\n", err)
		os.Exit(1)
	}

	fmt.Println("wrote part2/results/throughput.svg")
	fmt.Println("wrote part2/results/latency.svg")
}

func readRows(path string) ([]Row, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	reader := csv.NewReader(file)

	records, err := reader.ReadAll()
	if err != nil {
		return nil, err
	}

	var rows []Row

	for i, record := range records {
		if i == 0 {
			continue
		}

		gomax, err := strconv.Atoi(record[1])
		if err != nil {
			return nil, err
		}

		goroutines, err := strconv.Atoi(record[2])
		if err != nil {
			return nil, err
		}

		throughput, err := strconv.ParseFloat(record[6], 64)
		if err != nil {
			return nil, err
		}

		latency, err := strconv.ParseFloat(record[7], 64)
		if err != nil {
			return nil, err
		}

		rows = append(rows, Row{
			Workload:     record[0],
			GOMAXPROCS:   gomax,
			Goroutines:   goroutines,
			Throughput:   throughput,
			AvgLatencyUS: latency,
		})
	}

	return rows, nil
}

func writeChart(path string, rows []Row, metric string, yLabel string) error {
	const (
		width  = 1100.0
		height = 700.0
		left   = 90.0
		right  = 30.0
		top    = 70.0
		bottom = 90.0
	)

	workloads := uniqueWorkloads(rows)
	gomaxValues := uniqueGOMAXPROCS(rows)

	maxY := 0.0
	for _, r := range rows {
		value := metricValue(r, metric)
		if value > maxY {
			maxY = value
		}
	}

	if maxY <= 0 {
		maxY = 1
	}

	maxY = niceCeil(maxY)

	plotW := width - left - right
	plotH := height - top - bottom

	file, err := os.Create(path)
	if err != nil {
		return err
	}
	defer file.Close()

	fmt.Fprintf(file, `<svg xmlns="http://www.w3.org/2000/svg" width="%.0f" height="%.0f" viewBox="0 0 %.0f %.0f">`+"\n", width, height, width, height)
	fmt.Fprintln(file, `<rect width="100%" height="100%" fill="white"/>`)
	fmt.Fprintf(file, `<text x="%.0f" y="35" font-family="Arial" font-size="24" text-anchor="middle">%s by Goroutine Count</text>`+"\n", width/2, yLabel)

	// Axes
	fmt.Fprintf(file, `<line x1="%.0f" y1="%.0f" x2="%.0f" y2="%.0f" stroke="black"/>`+"\n", left, top, left, height-bottom)
	fmt.Fprintf(file, `<line x1="%.0f" y1="%.0f" x2="%.0f" y2="%.0f" stroke="black"/>`+"\n", left, height-bottom, width-right, height-bottom)

	// Y grid and labels
	for i := 0; i <= 5; i++ {
		value := maxY * float64(i) / 5.0
		y := height - bottom - (value/maxY)*plotH

		fmt.Fprintf(file, `<line x1="%.0f" y1="%.1f" x2="%.0f" y2="%.1f" stroke="#dddddd"/>`+"\n", left, y, width-right, y)
		fmt.Fprintf(file, `<text x="%.0f" y="%.1f" font-family="Arial" font-size="13" text-anchor="end">%.0f</text>`+"\n", left-8, y+4, value)
	}

	// X labels
	xValues := []int{1, 2, 4, 8, 16, 32, 64}
	for _, g := range xValues {
		x := xForGoroutines(g, left, plotW)
		fmt.Fprintf(file, `<line x1="%.1f" y1="%.0f" x2="%.1f" y2="%.0f" stroke="black"/>`+"\n", x, height-bottom, x, height-bottom+6)
		fmt.Fprintf(file, `<text x="%.1f" y="%.0f" font-family="Arial" font-size="13" text-anchor="middle">%d</text>`+"\n", x, height-bottom+25, g)
	}

	fmt.Fprintf(file, `<text x="%.0f" y="%.0f" font-family="Arial" font-size="16" text-anchor="middle">Goroutines</text>`+"\n", width/2, height-25)
	fmt.Fprintf(file, `<text transform="translate(25 %.0f) rotate(-90)" font-family="Arial" font-size="16" text-anchor="middle">%s</text>`+"\n", height/2, yLabel)

	colors := []string{
		"#1f77b4",
		"#ff7f0e",
		"#2ca02c",
		"#d62728",
		"#9467bd",
		"#8c564b",
	}

	seriesIndex := 0

	for _, workload := range workloads {
		for _, gomax := range gomaxValues {
			points := filterRows(rows, workload, gomax)
			sort.Slice(points, func(i, j int) bool {
				return points[i].Goroutines < points[j].Goroutines
			})

			color := colors[seriesIndex%len(colors)]
			label := fmt.Sprintf("%s GOMAXPROCS=%d", workload, gomax)

			var pathData string
			for i, p := range points {
				x := xForGoroutines(p.Goroutines, left, plotW)
				y := height - bottom - (metricValue(p, metric)/maxY)*plotH

				if i == 0 {
					pathData += fmt.Sprintf("M %.1f %.1f ", x, y)
				} else {
					pathData += fmt.Sprintf("L %.1f %.1f ", x, y)
				}

				fmt.Fprintf(file, `<circle cx="%.1f" cy="%.1f" r="4" fill="%s"/>`+"\n", x, y, color)
			}

			fmt.Fprintf(file, `<path d="%s" fill="none" stroke="%s" stroke-width="2"/>`+"\n", pathData, color)

			legendX := width - 290
			legendY := 90 + float64(seriesIndex)*24
			fmt.Fprintf(file, `<line x1="%.0f" y1="%.0f" x2="%.0f" y2="%.0f" stroke="%s" stroke-width="3"/>`+"\n", legendX, legendY, legendX+30, legendY, color)
			fmt.Fprintf(file, `<text x="%.0f" y="%.0f" font-family="Arial" font-size="14">%s</text>`+"\n", legendX+40, legendY+5, label)

			seriesIndex++
		}
	}

	fmt.Fprintln(file, `</svg>`)

	return nil
}

func metricValue(r Row, metric string) float64 {
	if metric == "throughput" {
		return r.Throughput
	}
	return r.AvgLatencyUS
}

func xForGoroutines(g int, left float64, plotW float64) float64 {
	// log2 scale for 1,2,4,8,16,32,64
	index := math.Log2(float64(g))
	return left + (index/6.0)*plotW
}

func niceCeil(value float64) float64 {
	pow := math.Pow(10, math.Floor(math.Log10(value)))
	scaled := value / pow

	switch {
	case scaled <= 2:
		return 2 * pow
	case scaled <= 5:
		return 5 * pow
	default:
		return 10 * pow
	}
}

func uniqueWorkloads(rows []Row) []string {
	seen := map[string]bool{}
	var values []string

	for _, r := range rows {
		if !seen[r.Workload] {
			seen[r.Workload] = true
			values = append(values, r.Workload)
		}
	}

	sort.Strings(values)
	return values
}

func uniqueGOMAXPROCS(rows []Row) []int {
	seen := map[int]bool{}
	var values []int

	for _, r := range rows {
		if !seen[r.GOMAXPROCS] {
			seen[r.GOMAXPROCS] = true
			values = append(values, r.GOMAXPROCS)
		}
	}

	sort.Ints(values)
	return values
}

func filterRows(rows []Row, workload string, gomax int) []Row {
	var filtered []Row

	for _, r := range rows {
		if r.Workload == workload && r.GOMAXPROCS == gomax {
			filtered = append(filtered, r)
		}
	}

	return filtered
}
