#!/bin/bash

set -e

#run go mod vendor
echo "Vendoring packages..."
go mod vendor

source config/dev.env
export $(cut -d= -f1 config/dev.env)
source config/secret.env
export $(cut -d= -f1 config/secret.env)

echo "Staring <serviceName>-service..."
go run src/main/server.go
