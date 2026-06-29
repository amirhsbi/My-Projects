# pubsub

This folder contains a simple HTTP-based Pub/Sub implementation in Go.

`publisher.go` runs the Pub/Sub broker. The web service publishes memory events to this broker.

`subscriber.go` connects to the broker and prints alerts when events are received.

## Default Port

```text
7000
```

## Run Broker

```bash
cd ~/pubsub
go run publisher.go
```

Expected output:

```text
PubSub broker started on 0.0.0.0:7000
```

## Run Subscriber

```bash
cd ~/pubsub
SUBSCRIBE_URL=http://192.168.29.130:7000/events go run subscriber.go
```

## Health Check

```bash
curl http://192.168.29.130:7000/health
```

## Manual Publish Test

This command can be used to test the broker and subscriber directly:

```bash
curl -X POST http://192.168.29.130:7000/publish -H "Content-Type: application/json" -d '{"event_type":"HIGH_MEMORY_USAGE","service":"web-server","memory_mb":345,"threshold_mb":300,"timestamp":"2026-06-01T12:00:00Z"}'
```

The subscriber should print:

```text
ALERT: HIGH MEMORY USAGE
```
