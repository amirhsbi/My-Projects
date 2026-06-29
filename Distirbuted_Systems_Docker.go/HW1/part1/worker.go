package main

import (
	"bufio"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"math"
	"os"
	"strconv"
	"strings"
	"syscall"
	"time"
)

const (
	requestPipe  = "/tmp/hw1_request.pipe"
	responsePipe = "/tmp/hw1_response.pipe"
)

type Response struct {
	OK        bool    `json:"ok"`
	Operation string  `json:"operation"`
	A         float64 `json:"a"`
	B         float64 `json:"b"`
	Result    *float64 `json:"result,omitempty"`
	Error     string  `json:"error,omitempty"`
}

func main() {
	log.SetFlags(log.LstdFlags | log.Lmicroseconds)

	if err := ensureFIFO(requestPipe); err != nil {
		log.Fatalf("failed to prepare request pipe: %v", err)
	}
	if err := ensureFIFO(responsePipe); err != nil {
		log.Fatalf("failed to prepare response pipe: %v", err)
	}

	log.Printf("worker started")
	log.Printf("request pipe: %s", requestPipe)
	log.Printf("response pipe: %s", responsePipe)
	log.Printf("waiting for requests...")

	for {
		reqFile, err := os.OpenFile(requestPipe, os.O_RDONLY, os.ModeNamedPipe)
		if err != nil {
			log.Printf("could not open request pipe: %v", err)
			time.Sleep(500 * time.Millisecond)
			continue
		}

		scanner := bufio.NewScanner(reqFile)
		for scanner.Scan() {
			line := strings.TrimSpace(scanner.Text())
			if line == "" {
				continue
			}

			log.Printf("received request: %q", line)

			resp := handleRequest(line)

			if err := sendResponse(resp); err != nil {
				log.Printf("failed to send response: %v", err)
			}
		}

		if err := scanner.Err(); err != nil {
			log.Printf("error while reading request pipe: %v", err)
		}

		if err := reqFile.Close(); err != nil {
			log.Printf("failed to close request pipe: %v", err)
		}
	}
}

func ensureFIFO(path string) error {
	info, err := os.Stat(path)
	if err == nil {
		if info.Mode()&os.ModeNamedPipe == 0 {
			return fmt.Errorf("%s exists but is not a named pipe", path)
		}
		return nil
	}

	if !errors.Is(err, os.ErrNotExist) {
		return err
	}

	if err := syscall.Mkfifo(path, 0666); err != nil {
		return err
	}

	return os.Chmod(path, 0666)
}

func sendResponse(resp Response) error {
	data, err := json.Marshal(resp)
	if err != nil {
		return err
	}

	respFile, err := os.OpenFile(responsePipe, os.O_WRONLY, os.ModeNamedPipe)
	if err != nil {
		return err
	}
	defer respFile.Close()

	_, err = fmt.Fprintln(respFile, string(data))
	return err
}

func handleRequest(line string) Response {
	fields := strings.Fields(line)
	if len(fields) != 3 {
		return Response{
			OK:    false,
			Error: "invalid_argument_count",
		}
	}

	op := strings.ToUpper(fields[0])

	a, err := strconv.ParseFloat(fields[1], 64)
	if err != nil {
		return Response{
			OK:    false,
			Error: "invalid_number_a",
		}
	}

	b, err := strconv.ParseFloat(fields[2], 64)
	if err != nil {
		return Response{
			OK:    false,
			Error: "invalid_number_b",
		}
	}

	result, errCode := compute(op, a, b)
	if errCode != "" {
		return Response{
			OK:        false,
			Operation: op,
			A:         a,
			B:         b,
			Error:     errCode,
		}
	}

	return Response{
		OK:        true,
		Operation: op,
		A:         a,
		B:         b,
		Result:    &result,
	}
}

func compute(op string, a, b float64) (float64, string) {
	switch op {
	case "ADD":
		return a + b, ""
	case "SUB":
		return a - b, ""
	case "MUL":
		return a * b, ""
	case "DIV":
		if b == 0 {
			return 0, "division_by_zero"
		}
		return a / b, ""

	// Extra operations for group distinction.
	case "MOD":
		if b == 0 {
			return 0, "modulo_by_zero"
		}
		return math.Mod(a, b), ""
	case "POW":
		return math.Pow(a, b), ""
	case "MAX":
		return math.Max(a, b), ""
	case "MIN":
		return math.Min(a, b), ""

	default:
		return 0, "unknown_operation"
	}
}
