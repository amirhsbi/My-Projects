package main

import (
	"bytes"
	"encoding/json"
	"html/template"
	"log"
	"net/http"
	"os"
	"runtime"
	"strconv"
	"sync"
	"time"
)

type LoginPageData struct {
	Error string
}

type WelcomePageData struct {
	Username string
	FileURL  string
}

type LoginParams struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

type RPCRequest struct {
	JSONRPC string      `json:"jsonrpc"`
	Method  string      `json:"method"`
	Params  LoginParams `json:"params"`
	ID      int         `json:"id"`
}

type LoginResult struct {
	Success bool   `json:"success"`
	Message string `json:"message"`
}

type RPCResponse struct {
	JSONRPC string       `json:"jsonrpc"`
	Result  *LoginResult `json:"result"`
	Error   string       `json:"error"`
	ID      int          `json:"id"`
}

type MemoryEvent struct {
	EventType   string `json:"event_type"`
	Service     string `json:"service"`
	MemoryMB    uint64 `json:"memory_mb"`
	ThresholdMB uint64 `json:"threshold_mb"`
	Timestamp   string `json:"timestamp"`
}

var authAddr string
var fileURL string
var brokerURL string
var memoryThresholdMB uint64
var allocatedMemory [][]byte
var memoryLock sync.Mutex
var alertState bool

func renderTemplate(w http.ResponseWriter, name string, data any) {
	t, err := template.ParseFiles("templates/" + name)
	if err != nil {
		http.Error(w, "template_error", http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	if err := t.Execute(w, data); err != nil {
		http.Error(w, "template_execute_error", http.StatusInternalServerError)
	}
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}
	renderTemplate(w, "login.html", LoginPageData{})
}

func loginHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/", http.StatusSeeOther)
		return
	}

	username := r.FormValue("username")
	password := r.FormValue("password")
	ok, err := callAuthRPC(username, password)
	if err != nil {
		renderTemplate(w, "login.html", LoginPageData{Error: "auth_service_unavailable"})
		return
	}
	if !ok {
		renderTemplate(w, "login.html", LoginPageData{Error: "invalid_username_or_password"})
		return
	}
	renderTemplate(w, "welcome.html", WelcomePageData{Username: username, FileURL: fileURL})
}

func callAuthRPC(username string, password string) (bool, error) {
	request := RPCRequest{JSONRPC: "2.0", Method: "Login", Params: LoginParams{Username: username, Password: password}, ID: 1}
	body, err := json.Marshal(request)
	if err != nil {
		return false, err
	}

	client := &http.Client{Timeout: 4 * time.Second}
	response, err := client.Post("http://"+authAddr+"/rpc", "application/json", bytes.NewReader(body))
	if err != nil {
		return false, err
	}
	defer response.Body.Close()

	var rpcResponse RPCResponse
	if err := json.NewDecoder(response.Body).Decode(&rpcResponse); err != nil {
		return false, err
	}
	if rpcResponse.Error != "" || rpcResponse.Result == nil {
		return false, nil
	}
	return rpcResponse.Result.Success, nil
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"status": "ok", "service": "web-vm"})
}

func readMemoryMB() (uint64, uint64, uint64) {
	var stats runtime.MemStats
	runtime.ReadMemStats(&stats)
	allocMB := stats.Alloc / 1024 / 1024
	heapAllocMB := stats.HeapAlloc / 1024 / 1024
	sysMB := stats.Sys / 1024 / 1024
	return allocMB, heapAllocMB, sysMB
}

func memoryHandler(w http.ResponseWriter, r *http.Request) {
	allocMB, heapAllocMB, sysMB := readMemoryMB()
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]uint64{
		"alloc_mb":      allocMB,
		"heap_alloc_mb": heapAllocMB,
		"sys_mb":        sysMB,
		"threshold_mb":  memoryThresholdMB,
	})
}

func consumeMemoryHandler(w http.ResponseWriter, r *http.Request) {
	mbText := r.URL.Query().Get("mb")
	if mbText == "" {
		mbText = "50"
	}
	mb, err := strconv.Atoi(mbText)
	if err != nil || mb <= 0 {
		http.Error(w, "invalid_mb", http.StatusBadRequest)
		return
	}
	chunk := make([]byte, mb*1024*1024)
	for i := 0; i < len(chunk); i += 4096 {
		chunk[i] = 1
	}
	memoryLock.Lock()
	allocatedMemory = append(allocatedMemory, chunk)
	memoryLock.Unlock()

	allocMB, heapAllocMB, sysMB := readMemoryMB()
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]any{
		"allocated_mb":  mb,
		"alloc_mb":      allocMB,
		"heap_alloc_mb": heapAllocMB,
		"sys_mb":        sysMB,
		"threshold_mb":  memoryThresholdMB,
	})
}

func monitorMemory() {
	for {
		allocMB, _, _ := readMemoryMB()
		if allocMB >= memoryThresholdMB {
			if !alertState {
				publishMemoryEvent(allocMB)
				alertState = true
			}
		} else {
			alertState = false
		}
		time.Sleep(2 * time.Second)
	}
}

func publishMemoryEvent(memoryMB uint64) {
	event := MemoryEvent{
		EventType:   "HIGH_MEMORY_USAGE",
		Service:     "web-server",
		MemoryMB:    memoryMB,
		ThresholdMB: memoryThresholdMB,
		Timestamp:   time.Now().UTC().Format(time.RFC3339),
	}
	body, err := json.Marshal(event)
	if err != nil {
		log.Println("memory event marshal error:", err)
		return
	}
	client := &http.Client{Timeout: 3 * time.Second}
	resp, err := client.Post(brokerURL, "application/json", bytes.NewReader(body))
	if err != nil {
		log.Println("memory event publish error:", err)
		return
	}
	resp.Body.Close()
	log.Println("memory event published:", memoryMB, "MB")
}

func main() {
	authAddr = os.Getenv("AUTH_ADDR")
	if authAddr == "" {
		authAddr = "127.0.0.1:9000"
	}
	fileURL = os.Getenv("FILE_URL")
	if fileURL == "" {
		fileURL = "http://127.0.0.1:9090/images/sample.svg"
	}
	brokerURL = os.Getenv("BROKER_URL")
	if brokerURL == "" {
		brokerURL = "http://127.0.0.1:7000/publish"
	}
	memoryThresholdMB = 300
	if value := os.Getenv("MEMORY_THRESHOLD_MB"); value != "" {
		parsed, err := strconv.ParseUint(value, 10, 64)
		if err == nil && parsed > 0 {
			memoryThresholdMB = parsed
		}
	}
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	http.HandleFunc("/", homeHandler)
	http.HandleFunc("/login", loginHandler)
	http.HandleFunc("/health", healthHandler)
	http.HandleFunc("/memory", memoryHandler)
	http.HandleFunc("/consume-memory", consumeMemoryHandler)
	http.Handle("/static/", http.StripPrefix("/static/", http.FileServer(http.Dir("static"))))

	go monitorMemory()

	log.Println("web service started on 0.0.0.0:" + port)
	log.Println("auth address: " + authAddr)
	log.Println("file url: " + fileURL)
	log.Println("broker url: " + brokerURL)
	log.Println("memory threshold mb:", memoryThresholdMB)
	log.Fatal(http.ListenAndServe("0.0.0.0:"+port, nil))
}
