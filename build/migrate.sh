#!/bin/bash

ServiceName="<serviceName>"
DBPort=5432
DBName="host.docker.internal"
MigratePath=`pwd`"/build/migration"
echo "Running migrations from $MigratePath on postgres: $DBName:$DBPort"
docker run --rm -ti -v "$MigratePath":/migration awayteam/migrate:latest -url "postgres://postgres:password@$DBName:$DbPort/$ServiceName?sslmode=disable" -path /migration up

