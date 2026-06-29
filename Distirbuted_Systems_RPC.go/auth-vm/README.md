# auth-vm

This service runs on VM2. It stores user data in `users.json` and exposes a JSON-RPC login method.

Passwords are not stored in plain text. The file stores SHA-256 password hashes. When a login request is received, the input password is hashed and compared with the stored hash.

## Default Port

```text
9000
```

## Run

```bash
cd ~/auth-vm
go run main.go
```

## Health Check

```bash
curl http://192.168.29.131:9000/health
```

## JSON-RPC Login Test

Successful login:

```bash
curl -X POST http://192.168.29.131:9000/rpc -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"Login","params":{"username":"alice","password":"alice123"},"id":1}'
```

Wrong login:

```bash
curl -X POST http://192.168.29.131:9000/rpc -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"Login","params":{"username":"alice","password":"wrong"},"id":2}'
```

## Test Users

| Username | Password |
|---|---|
| alice | alice123 |
| bob | bob123 |
| admin | admin123 |
