# file-vm

This service runs on VM3. It serves files and images through HTTP.

## Default Port

```text
9090
```

## Run

```bash
cd ~/file-vm
go run main.go
```

## Health Check

```bash
curl http://192.168.29.129:9090/health
```

## Test File

```bash
curl http://192.168.29.129:9090/files/info.txt
```

## Test Images

Open one of these URLs in the browser:

```text
http://192.168.29.129:9090/images/sample.svg
http://192.168.29.129:9090/images/Saul.jpg
http://192.168.29.129:9090/images/messi.jpg
```

VM1 uses the image URL through `FILE_URL`, so the file is received from VM3 through the network and not from a local path on VM1.
