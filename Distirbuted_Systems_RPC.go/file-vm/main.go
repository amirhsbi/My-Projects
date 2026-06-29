package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
)

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"status": "ok", "service": "file-vm"})
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "9090"
	}

	http.HandleFunc("/health", healthHandler)
	http.Handle("/images/", http.StripPrefix("/images/", http.FileServer(http.Dir("images"))))
	http.Handle("/files/", http.StripPrefix("/files/", http.FileServer(http.Dir("files"))))

	log.Println("file service started on 0.0.0.0:" + port)
	log.Fatal(http.ListenAndServe("0.0.0.0:"+port, nil))
}
