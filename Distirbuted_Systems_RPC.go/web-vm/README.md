# web-vm

This service runs the web login page on VM1. It does not authenticate users locally. It sends a JSON-RPC request to the auth service on VM2. After a successful login, it displays an image served by VM3.

The same service also monitors its own memory usage and publishes a high memory event to the Pub/Sub broker when the threshold is passed.

## Default Port

```text
8080
```

## Environment Variables

| Variable | Purpose | Example |
|---|---|---|
| AUTH_ADDR | Address of auth-vm JSON-RPC service | 192.168.29.131:9000 |
| FILE_URL | Image URL served by file-vm | http://192.168.29.129:9090/images/sample.svg |
| BROKER_URL | Pub/Sub publish endpoint | http://192.168.29.130:7000/publish |
| MEMORY_THRESHOLD_MB | Memory alert threshold | 300 |
| PORT | Web server port | 8080 |

## Run

```bash
cd ~/web-vm
AUTH_ADDR=192.168.29.131:9000 FILE_URL=http://192.168.29.129:9090/images/sample.svg BROKER_URL=http://192.168.29.130:7000/publish MEMORY_THRESHOLD_MB=300 go run main.go
```

## Open in Browser

```text
http://192.168.29.130:8080
```

## Test Users

| Username | Password |
|---|---|
| alice | alice123 |
| bob | bob123 |
| admin | admin123 |

## Health Check

```bash
curl http://192.168.29.130:8080/health
```

## Memory Check

```bash
curl http://192.168.29.130:8080/memory
```

## Increase Memory

```bash
curl "http://192.168.29.130:8080/consume-memory?mb=100"
```

Run the command multiple times until the threshold is passed. The subscriber should receive a high memory alert.
