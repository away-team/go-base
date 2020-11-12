#!/bin/bash

set -e

#### Config Vars ####
# update these to reflect your service
source `pwd`/build/vars.sh
BasePath="/home/core/dev/"
port="8080"
dbPort="5432"
buildContainer="golang:1.15"
networkName="internal"
# the local config file to push in to the config store
localConfigFile="$(pwd)/config/local.json"
# enable/disable config push with -c
pushConfig=true

# The config env file to pass to docker run
EnvFile="`pwd`/config/dev.env"
if [ ! -f $EnvFile ];
then
  echo "Cannot find ${EnvFile}"
  exit 1
fi

SecretEnvFile="`pwd`/config/secret.env"
IncludeSecret="--env-file `pwd`/config/secret.env"
if [ ! -f $SecretEnvFile ];
then
  IncludeSecret=""
fi

# Default to using the ip of eth1 as the "externally reachable" interface
HostIP="localhost"
# Use CoreOS injected vars if they are available
MetaDataFile="/run/metadata/coreos"
if [ -f $MetaDataFile ];
then
  source $MetaDataFile
  HostIP=$COREOS_VAGRANT_VIRTUALBOX_PRIVATE_IPV4
fi

#handle args
while getopts ":p:c" opt; do
  case $opt in
    p)
      port=$OPTARG
      echo "port overridden to $port"
      ;;
    c)
      pushConfig=false
      echo "Config push disabled"
      ;;
  esac
done

# determine service path for volume mounting
CurrentDir=`pwd`
ServicePath="${CurrentDir/$BasePath/}"

# running go mod
echo "vendoring packages..."
go mod vendor

# run the build
echo "Building service"
docker run --rm -it -v `pwd`:"/go/src/$ServicePath" -w /go/src/$ServicePath $buildContainer ./build/build.sh || { echo 'build failed' ; exit 1; }

# build the docker container with the new binary
docker build -t $ServiceName .
docker build -t $ServiceName-migrate -f Dockerfile.migrate .

# If a user defined docker network does not exist, create it
networkExists=$(docker network ls -q -f "name=$networkName")
if [ "$networkExists" == "" ]
then
  echo "Creating network: $networkName"
  docker network create -d bridge $networkName
fi

# run the DB container
DBName="$ServiceName-db"
# only run the db if it isnt already running
running=$(docker ps -q -f "name=$DBName" -f "status=running" )
if [ "$running" == "" ]
  then
  docker rm $DBName &>/dev/null || true
  docker run --network $networkName --name $DBName -e POSTGRES_PASSWORD=password -e POSTGRES_DB=$ServiceName -P -d postgres:10.5
  sleep 10
fi

# run the migrations
DBPort=5432
echo "Running migrations on postgres: $DBName:$DBPort"
docker run --rm --network $networkName -ti $ServiceName-migrate -url "postgres://postgres:password@$DBName:$DbPort/$ServiceName?sslmode=disable" -path /migration up

# update parameter store config
if [ "$pushConfig" ] && [ -f "$localConfigFile" ]
then
  echo "Pushing config"
  docker run -ti --rm -v $localConfigFile:/config/local.json $IncludeSecret healthimation/go-aws-config -file /config/local.json -env $EnvironmentName -service $ServiceName
else
  echo "$localConfigFile not found, skipping config push"
fi

# run the container
docker run --rm --network $networkName -it -p $port:8080 --env-file $EnvFile $IncludeSecret $ServiceName
