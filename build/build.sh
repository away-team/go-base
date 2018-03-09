#!/bin/bash

# Build the service
CGO_ENABLED=0 go build -a -ldflags "-s" -installsuffix cgo -o bin/app src/main/*.go
