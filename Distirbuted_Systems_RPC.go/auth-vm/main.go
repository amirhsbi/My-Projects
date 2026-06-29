package main

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"log"
	"net/http"
	"os"
)

type User struct {
	Username     string `json:"username"`
	PasswordHash string `json:"password_hash"`
}

type LoginParams struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

type RPCRequest struct {
	JSONRPC string          `json:"jsonrpc"`
	Method  string          `json:"method"`
	Params  json.RawMessage `json:"params"`
	ID      any             `json:"id"`
}

type LoginResult struct {
	Success bool   `json:"success"`
	Message string `json:"message"`
}

type RPCResponse struct {
	JSONRPC string       `json:"jsonrpc"`
	Result  *LoginResult `json:"result,omitempty"`
	Error   string       `json:"error,omitempty"`
	ID      any          `json:"id,omitempty"`
}

var users []User

func loadUsers() {
	data, err := os.ReadFile("users.json")
	if err != nil {
		log.Fatal("cannot read users.json: ", err)
	}
	if err := json.Unmarshal(data, &users); err != nil {
		log.Fatal("invalid users.json: ", err)
	}
}

func hashPassword(password string) string {
	sum := sha256.Sum256([]byte(password))
	return hex.EncodeToString(sum[:])
}

func checkLogin(username string, password string) bool {
	passwordHash := hashPassword(password)
	for _, user := range users {
		if user.Username == username && user.PasswordHash == passwordHash {
			return true
		}
	}
	return false
}

func rpcHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		json.NewEncoder(w).Encode(RPCResponse{JSONRPC: "2.0", Error: "method_not_allowed"})
		return
	}

	var request RPCRequest
	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(RPCResponse{JSONRPC: "2.0", Error: "invalid_json"})
		return
	}

	if request.Method != "Login" {
		json.NewEncoder(w).Encode(RPCResponse{JSONRPC: "2.0", Error: "unknown_method", ID: request.ID})
		return
	}

	var params LoginParams
	if err := json.Unmarshal(request.Params, &params); err != nil {
		json.NewEncoder(w).Encode(RPCResponse{JSONRPC: "2.0", Error: "invalid_params", ID: request.ID})
		return
	}

	if checkLogin(params.Username, params.Password) {
		json.NewEncoder(w).Encode(RPCResponse{JSONRPC: "2.0", Result: &LoginResult{Success: true, Message: "login_successful"}, ID: request.ID})
		return
	}

	json.NewEncoder(w).Encode(RPCResponse{JSONRPC: "2.0", Result: &LoginResult{Success: false, Message: "invalid_credentials"}, ID: request.ID})
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"status": "ok", "service": "auth-vm"})
}

func main() {
	loadUsers()
	port := os.Getenv("PORT")
	if port == "" {
		port = "9000"
	}
	http.HandleFunc("/rpc", rpcHandler)
	http.HandleFunc("/health", healthHandler)
	log.Println("auth service started on 0.0.0.0:" + port)
	log.Fatal(http.ListenAndServe("0.0.0.0:"+port, nil))
}
