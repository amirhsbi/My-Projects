FROM docker.darvagcloud.com/library/golang:1.22-bookworm AS builder

WORKDIR /src

ENV GOPROXY=https://package-mirror.darvagcloud.com/go

COPY go.mod ./
COPY part3/main.go ./part3/main.go

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /out/hw1-compute-service ./part3/main.go

FROM docker.darvagcloud.com/library/debian:bookworm-slim

WORKDIR /app

COPY --from=builder /out/hw1-compute-service /app/hw1-compute-service

ENV PORT=8080

EXPOSE 8080

CMD ["/app/hw1-compute-service"]
