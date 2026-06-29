package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"
	"time"
)

type Event struct {
	EventType   string `json:"event_type"`
	Service     string `json:"service"`
	MemoryMB    uint64 `json:"memory_mb"`
	ThresholdMB uint64 `json:"threshold_mb"`
	Timestamp   string `json:"timestamp"`
}

func main() {
	url := os.Getenv("SUBSCRIBE_URL")
	if url == "" {
		url = "http://127.0.0.1:7000/events"
	}

	for {
		err := subscribe(url)
		log.Println("subscriber reconnecting after error:", err)
		time.Sleep(2 * time.Second)
	}
}

func subscribe(url string) error {
	resp, err := http.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("bad status: %s", resp.Status)
	}
	log.Println("subscriber connected to", url)
	scanner := bufio.NewScanner(resp.Body)
	for scanner.Scan() {
		line := scanner.Text()
		if !strings.HasPrefix(line, "data: ") {
			continue
		}
		payload := strings.TrimPrefix(line, "data: ")
		var event Event
		if err := json.Unmarshal([]byte(payload), &event); err != nil {
			log.Println("invalid event:", err)
			continue
		}
		fmt.Println("ALERT: HIGH MEMORY USAGE")
		fmt.Println("service:", event.Service)
		fmt.Println("memory_mb:", event.MemoryMB)
		fmt.Println("threshold_mb:", event.ThresholdMB)
		fmt.Println("timestamp:", event.Timestamp)
		fmt.Println("event_type:", event.EventType)
		fmt.Println("---")
	}
	return scanner.Err()
}
