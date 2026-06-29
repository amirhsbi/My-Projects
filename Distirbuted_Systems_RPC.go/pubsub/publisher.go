package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"sync"
	"time"
)

type Event struct {
	EventType   string `json:"event_type"`
	Service     string `json:"service"`
	MemoryMB    uint64 `json:"memory_mb"`
	ThresholdMB uint64 `json:"threshold_mb"`
	Timestamp   string `json:"timestamp"`
}

type Broker struct {
	mu          sync.Mutex
	subscribers map[chan Event]bool
}

func NewBroker() *Broker {
	return &Broker{subscribers: make(map[chan Event]bool)}
}

func (b *Broker) addSubscriber() chan Event {
	ch := make(chan Event, 10)
	b.mu.Lock()
	b.subscribers[ch] = true
	b.mu.Unlock()
	return ch
}

func (b *Broker) removeSubscriber(ch chan Event) {
	b.mu.Lock()
	delete(b.subscribers, ch)
	close(ch)
	b.mu.Unlock()
}

func (b *Broker) publish(event Event) int {
	b.mu.Lock()
	defer b.mu.Unlock()
	count := 0
	for ch := range b.subscribers {
		select {
		case ch <- event:
			count++
		default:
		}
	}
	return count
}

func main() {
	broker := NewBroker()
	port := os.Getenv("PORT")
	if port == "" {
		port = "7000"
	}

	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]string{"status": "ok", "service": "pubsub-broker"})
	})

	http.HandleFunc("/publish", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		if r.Method != http.MethodPost {
			w.WriteHeader(http.StatusMethodNotAllowed)
			json.NewEncoder(w).Encode(map[string]string{"error": "method_not_allowed"})
			return
		}
		var event Event
		if err := json.NewDecoder(r.Body).Decode(&event); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			json.NewEncoder(w).Encode(map[string]string{"error": "invalid_json"})
			return
		}
		if event.Timestamp == "" {
			event.Timestamp = time.Now().UTC().Format(time.RFC3339)
		}
		count := broker.publish(event)
		log.Printf("published event=%s memory=%d threshold=%d subscribers=%d", event.EventType, event.MemoryMB, event.ThresholdMB, count)
		json.NewEncoder(w).Encode(map[string]any{"status": "published", "subscribers": count})
	})

	http.HandleFunc("/events", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/event-stream")
		w.Header().Set("Cache-Control", "no-cache")
		w.Header().Set("Connection", "keep-alive")
		flusher, ok := w.(http.Flusher)
		if !ok {
			http.Error(w, "streaming not supported", http.StatusInternalServerError)
			return
		}
		ch := broker.addSubscriber()
		defer broker.removeSubscriber(ch)
		log.Println("subscriber connected")
		fmt.Fprintf(w, ": connected\n\n")
		flusher.Flush()
		for {
			select {
			case event := <-ch:
				data, _ := json.Marshal(event)
				fmt.Fprintf(w, "data: %s\n\n", data)
				flusher.Flush()
			case <-r.Context().Done():
				log.Println("subscriber disconnected")
				return
			}
		}
	})

	log.Println("PubSub broker started on 0.0.0.0:" + port)
	log.Fatal(http.ListenAndServe("0.0.0.0:"+port, nil))
}
