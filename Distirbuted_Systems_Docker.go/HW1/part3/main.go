package main

import (
	"encoding/json"
	"log"
	"math"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"
)

type HealthResponse struct {
	Status    string `json:"status"`
	Timestamp string `json:"timestamp"`
}

type ComputeResponse struct {
	Operation string  `json:"operation"`
	A         float64 `json:"a"`
	B         float64 `json:"b"`
	Result    *float64 `json:"result,omitempty"`
	Error     string  `json:"error,omitempty"`
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/health", withLogging(healthHandler))
	mux.HandleFunc("/compute", withLogging(computeHandler))

	addr := ":" + port

	log.Printf("starting HW1 compute service on %s", addr)

	if err := http.ListenAndServe(addr, mux); err != nil {
		log.Fatalf("server failed: %v", err)
	}
}

func withLogging(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()

		next(w, r)

		log.Printf(
			"%s %s from=%s duration=%s",
			r.Method,
			r.URL.String(),
			r.RemoteAddr,
			time.Since(start),
		)
	}
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		writeError(w, http.StatusMethodNotAllowed, "method_not_allowed")
		return
	}

	writeJSON(w, http.StatusOK, HealthResponse{
		Status:    "ok",
		Timestamp: time.Now().UTC().Format(time.RFC3339),
	})
}

func computeHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		writeError(w, http.StatusMethodNotAllowed, "method_not_allowed")
		return
	}

	query := r.URL.Query()

	op := strings.ToLower(strings.TrimSpace(query.Get("op")))
	aText := strings.TrimSpace(query.Get("a"))
	bText := strings.TrimSpace(query.Get("b"))

	if op == "" || aText == "" || bText == "" {
		writeError(w, http.StatusBadRequest, "missing_required_parameter")
		return
	}

	a, err := strconv.ParseFloat(aText, 64)
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid_number_a")
		return
	}

	b, err := strconv.ParseFloat(bText, 64)
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid_number_b")
		return
	}

	result, errCode := compute(op, a, b)
	if errCode != "" {
		status := http.StatusBadRequest
		writeJSON(w, status, ComputeResponse{
			Operation: op,
			A:         a,
			B:         b,
			Error:     errCode,
		})
		return
	}

	writeJSON(w, http.StatusOK, ComputeResponse{
		Operation: op,
		A:         a,
		B:         b,
		Result:    &result,
	})
}

func compute(op string, a float64, b float64) (float64, string) {
	switch op {
	case "add":
		return a + b, ""
	case "sub":
		return a - b, ""
	case "mul":
		return a * b, ""
	case "div":
		if b == 0 {
			return 0, "division_by_zero"
		}
		return a / b, ""

	// Extra operations for group distinction.
	case "mod":
		if b == 0 {
			return 0, "modulo_by_zero"
		}
		return math.Mod(a, b), ""
	case "pow":
		return math.Pow(a, b), ""
	case "max":
		return math.Max(a, b), ""
	case "min":
		return math.Min(a, b), ""

	default:
		return 0, "invalid_operation"
	}
}

func writeJSON(w http.ResponseWriter, status int, payload any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)

	if err := json.NewEncoder(w).Encode(payload); err != nil {
		log.Printf("failed to encode JSON response: %v", err)
	}
}

func writeError(w http.ResponseWriter, status int, code string) {
	writeJSON(w, status, map[string]string{
		"error": code,
	})
}

