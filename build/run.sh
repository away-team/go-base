#!/bin/bash

#### Config Vars ####
# update these to reflect your service
source `pwd`/build/vars.sh
BasePath="/home/core/dev/"
port="8080"
dbPort="5432"
buildContainer="golang:1.9.4"

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
HostIP=$(ip -4 add show eth1 |grep inet | cut -d ' ' -f6 | cut -d '/' -f1)
# Use CoreOS injected vars if they are available
MetaDataFile="/run/metadata/coreos"
if [ -f $MetaDataFile ];
then
  source $MetaDataFile
  HostIP=$COREOS_VAGRANT_VIRTUALBOX_PRIVATE_IPV4
fi

#handle args
while getopts ":p:" opt; do
  case $opt in
    p)
      port=$OPTARG
      echo "port overridden to $port"
      ;;
  esac
done

# determine service path for volume mounting
CurrentDir=`pwd`
ServicePath="${CurrentDir/$BasePath/}"

# run the build
echo "Building service"
docker run --rm -it -v `pwd`:"/go/src/$ServicePath" -w /go/src/$ServicePath $buildContainer ./build/build.sh || { echo 'build failed' ; exit 1; }

# build the docker container with the new binary
docker build -t $ServiceName .
docker build -t $ServiceName-migrate -f Dockerfile.migrate .


# run the DB container
DBName="$ServiceName-db"
# only run the db if it isnt already running
running=$(docker ps -q -f "name=$DBName" -f "status=running" )
if [ "$running" == "" ]
  then
  docker rm $DBName &>/dev/null
  docker run --name $DBName -e SERVICE_NAME=$DBName -e POSTGRES_PASSWORD=password -e POSTGRES_DB=$ServiceName -P -d postgres:9.6
  sleep 10
fi

# run the migrations
DBPort=5432
echo "Running migrations on postgres: $DBName:$DBPort"
docker run --rm -ti $ServiceName-migrate -url "postgres://postgres:password@$DBName:$DbPort/$ServiceName?sslmode=disable" -path /migration up


# run the container
docker run --rm -it -p $port:8080 --env-file $EnvFile $IncludeSecret -e SERVICE_NAME=$ServiceName $ServiceName
