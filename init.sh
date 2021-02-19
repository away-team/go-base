#!/bin/bash

if [ -z ${1+x} ]; then
  printf "Service name is not set.\n sh init.sh <serviceName>\n"
  exit 1
else
  echo "Using service name '$1'"
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

echo "Replacing <serviceName> with $1..."
find "$DIR/build" -type f -name '*.sh' -print0 | xargs -0 sed -i '' "s/<serviceName>/$1/g"
find "$DIR/config" -type f -name '*.env' -print0 | xargs -0 sed -i '' "s/<serviceName>/$1/g"
find "$DIR/src/main" -type f -name '*.go' -print0 | xargs -0 sed -i '' "s/<serviceName>/$1/g"
find "$DIR/src/server/serviceName" -type f -name '*.go' -print0 | xargs -0 sed -i '' "s/<serviceName>/$1/g"
find "$DIR/src/internal" -type f -name '*.go' -print0 | xargs -0 sed -i '' "s/<serviceName>/$1/g"
find "$DIR/src/serviceName" -type f -name '*.go' -print0 | xargs -0 sed -i '' "s/<serviceName>/$1/g"
sed -i '' "s/<serviceName>/$1/g" README.md
sed -i '' "s/<serviceName>/$1/g" devspace.yaml

echo "Moving serviceName directories..."
mv "$DIR/src/server/serviceName" "$DIR/src/server/$1"
mv "$DIR/src/serviceName" "$DIR/src/$1"

echo "Initializing Go modules for $1..."
go mod init "github.com/HqOapp/$1-service"

echo "Creating empty secret.env file..."
touch "$DIR/config/secret.env"

echo "Creating Swagger documentation directory..."
mkdir -p "$DIR/doc/swagger/v1"

printf "\nFinished.  Don't forget to remove this script update the README.md.\n"

# Delete this script.
rm -- "$0"
