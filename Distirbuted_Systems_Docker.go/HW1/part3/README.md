# HW1 - Part 3: HTTP Service, Docker, and VM Deployment

## Overview

This part implements a simple HTTP compute service in Go, containerizes it with Docker, runs it inside the Ubuntu VM, and exposes it through VM networking.

The service provides two required endpoints:

- `GET /health`
- `GET /compute`

Only Go standard-library packages are used.

## Files

    part3/
    ├── main.go
    ├── Dockerfile
    ├── README.md
    ├── server
    └── evidence/
        ├── container-local-test.txt
        ├── container-final-logs.txt
        └── public-dnat-test.txt

## Endpoints

### Health Check

    GET /health

Example response:

    {"status":"ok","timestamp":"2026-05-08T18:44:02Z"}

### Compute

    GET /compute?op=add&a=5&b=7

Example response:

    {"operation":"add","a":5,"b":7,"result":12}

Supported required operations:

- `add`
- `sub`
- `mul`
- `div`

Extra operations implemented for group distinction:

- `mod`
- `pow`
- `max`
- `min`

## Error Handling

The service handles:

- Missing parameters
- Invalid operation
- Non-numeric `a`
- Non-numeric `b`
- Division by zero
- Modulo by zero
- Wrong HTTP method

Example division-by-zero request:

    GET /compute?op=div&a=8&b=0

Response:

    {"operation":"div","a":8,"b":0,"error":"division_by_zero"}

Wrong method example:

    POST /compute?op=add&a=1&b=2

Response:

    {"error":"method_not_allowed"}

## Build and Run Without Docker

From the `HW1` root directory:

    go build -o part3/server part3/main.go
    PORT=8080 ./part3/server

Test locally:

    curl -i http://127.0.0.1:8080/health
    curl -i "http://127.0.0.1:8080/compute?op=add&a=5&b=7"

## Docker Image Build

The Dockerfile uses Darvag's Docker mirror for base images:

    docker.darvagcloud.com/library/golang:1.22-bookworm
    docker.darvagcloud.com/library/debian:bookworm-slim

Build command:

    docker build -t hw1-compute-service:latest -f part3/Dockerfile .

## Docker Container Run

Run the container inside the VM:

    docker run -d \
      --name hw1-compute-service \
      -p 8080:8080 \
      hw1-compute-service:latest

Check container status:

    docker ps
    docker logs hw1-compute-service

## Local VM Test

From inside the VM:

    curl -i http://127.0.0.1:8080/health
    curl -i "http://127.0.0.1:8080/compute?op=add&a=5&b=7"
    curl -i "http://127.0.0.1:8080/compute?op=pow&a=2&b=8"

## Host-to-VM Access

The VM private address is:

    192.168.1.13/24

The Docker container publishes the service on:

    0.0.0.0:8080->8080/tcp

A firewall DNAT rule was configured on the Sangfor cluster:

    Public IP:       89.38.215.235
    Public port:     18080
    Internal target: 192.168.1.13
    Internal port:   8080
    Protocol:        TCP

External test commands:

    curl -i http://89.38.215.235:18080/health
    curl -i "http://89.38.215.235:18080/compute?op=add&a=5&b=7"
    curl -i "http://89.38.215.235:18080/compute?op=div&a=8&b=0"

This proves that a request from outside the VM reaches the containerized Go service running inside the VM.
