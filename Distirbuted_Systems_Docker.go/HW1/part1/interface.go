package main

import (
	"bufio"
	"errors"
	"fmt"
	"os"
	"strings"
	"time"
)

const (
	requestPipe  = "/tmp/hw1_request.pipe"
	responsePipe = "/tmp/hw1_response.pipe"
)

func main() {
	if len(os.Args) > 1 {
		request := strings.Join(os.Args[1:], " ")
		if err := sendAndReceive(request); err != nil {
			fmt.Fprintf(os.Stderr, "error: %v\n", err)
			os.Exit(1)
		}
		return
	}

	fmt.Println("HW1 Part1 Interface")
	fmt.Println("Enter requests in this format: OP A B")
	fmt.Println("Examples: ADD 5 7 | DIV 8 2 | MOD 10 3 | POW 2 8")
	fmt.Println("Type exit to quit.")

	scanner := bufio.NewScanner(os.Stdin)
	for {
		fmt.Print("> ")

		if !scanner.Scan() {
			break
		}

		line := strings.TrimSpace(scanner.Text())
		if line == "" {
			continue
		}

		if strings.EqualFold(line, "exit") || strings.EqualFold(line, "quit") {
			fmt.Println("bye")
			return
		}

		if err := sendAndReceive(line); err != nil {
			fmt.Fprintf(os.Stderr, "error: %v\n", err)
		}
	}

	if err := scanner.Err(); err != nil {
		fmt.Fprintf(os.Stderr, "stdin error: %v\n", err)
	}
}

func sendAndReceive(request string) error {
	if !isNamedPipe(requestPipe) {
		return fmt.Errorf("request pipe is missing; is the worker running? expected %s", requestPipe)
	}

	if !isNamedPipe(responsePipe) {
		return fmt.Errorf("response pipe is missing; is the worker running? expected %s", responsePipe)
	}

	reqFile, err := os.OpenFile(requestPipe, os.O_WRONLY, os.ModeNamedPipe)
	if err != nil {
		return fmt.Errorf("could not open request pipe; worker may not be running: %w", err)
	}

	_, writeErr := fmt.Fprintln(reqFile, request)
	closeErr := reqFile.Close()

	if writeErr != nil {
		return fmt.Errorf("could not write request to pipe: %w", writeErr)
	}

	if closeErr != nil {
		return fmt.Errorf("could not close request pipe: %w", closeErr)
	}

	respFile, err := os.OpenFile(responsePipe, os.O_RDONLY, os.ModeNamedPipe)
	if err != nil {
		return fmt.Errorf("could not open response pipe: %w", err)
	}
	defer respFile.Close()

	responseCh := make(chan string, 1)
	errorCh := make(chan error, 1)

	go func() {
		reader := bufio.NewReader(respFile)
		response, err := reader.ReadString('\n')
		if err != nil {
			errorCh <- err
			return
		}
		responseCh <- strings.TrimSpace(response)
	}()

	select {
	case response := <-responseCh:
		fmt.Println(response)
		return nil
	case err := <-errorCh:
		return fmt.Errorf("could not read response from worker: %w", err)
	case <-time.After(5 * time.Second):
		return errors.New("timeout waiting for worker response")
	}
}

func isNamedPipe(path string) bool {
	info, err := os.Stat(path)
	if err != nil {
		return false
	}

	return info.Mode()&os.ModeNamedPipe != 0
}
