# HW1 - Part 1: IPC with Named Pipes

## Overview

This part implements two independent Go processes:

- `worker.go`: a persistent computation worker.
- `interface.go`: a user-facing client that sends requests and prints responses.

The two processes communicate through Linux named pipes, also called FIFOs. This part does not use sockets and does not use regular files as an IPC replacement.

## Files

    part1/
    ├── interface.go
    ├── worker.go
    ├── README.md
    └── evidence/
        ├── part1-tests.txt
        └── worker-log.txt

## Requirements

- Go 1.22+
- Linux
- No external Go libraries

The implementation only uses Go standard-library packages.

## IPC Design

Two named pipes are used:

    /tmp/hw1_request.pipe
    /tmp/hw1_response.pipe

The Interface writes one request line to the request pipe.

The Worker reads the request, computes the result, and writes one JSON response line to the response pipe.

The Worker remains alive after each request and can process multiple sequential requests without restarting.

## Request Format

    OP A B

Where:

- `OP` is the operation name.
- `A` and `B` are numeric operands.

Required operations:

- `ADD`
- `SUB`
- `MUL`
- `DIV`

Extra operations implemented for group distinction:

- `MOD`
- `POW`
- `MAX`
- `MIN`

## Response Format

Responses are JSON objects.

Successful response example:

    {"ok":true,"operation":"ADD","a":5,"b":7,"result":12}

Error response example:

    {"ok":false,"operation":"DIV","a":8,"b":0,"error":"division_by_zero"}

## Build

From the `HW1` root directory:

    go build -o part1/worker part1/worker.go
    go build -o part1/interface part1/interface.go

## Correct Execution Order

Start the Worker first:

    ./part1/worker

Then run the Interface in another terminal:

    ./part1/interface

Or send a single request directly:

    ./part1/interface ADD 5 7

## Example Commands and Outputs

    $ ./part1/interface ADD 5 7
    {"ok":true,"operation":"ADD","a":5,"b":7,"result":12}

    $ ./part1/interface DIV 8 2
    {"ok":true,"operation":"DIV","a":8,"b":2,"result":4}

    $ ./part1/interface DIV 8 0
    {"ok":false,"operation":"DIV","a":8,"b":0,"error":"division_by_zero"}

    $ ./part1/interface ABC 1 2
    {"ok":false,"operation":"ABC","a":1,"b":2,"error":"unknown_operation"}

    $ ./part1/interface ADD x 2
    {"ok":false,"error":"invalid_number_a"}

## Error Handling

The implementation handles:

- Unknown operation
- Invalid argument count
- Non-numeric input
- Division by zero
- Modulo by zero
- Missing pipes
- Worker not running
- Unexpected pipe read/write errors

## Cleanup

To stop the background Worker if it was started with `&`:

    kill "$(cat /tmp/hw1_worker.pid)"

To remove named pipes:

    rm -f /tmp/hw1_request.pipe /tmp/hw1_response.pipe
