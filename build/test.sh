#!/bin/bash

source `pwd`/build/vars.sh
verboseMode=""
runOpt=""

#handle args
while getopts ":vr:" opt; do
  case $opt in
    v)
      verboseMode="-v"
      ;;
    r)
      runOpt="-run (?i)$OPTARG"
      ;;
  esac
done


# find all go packages
packages="$(find src -type f -name "*.go" -exec dirname {} \; | grep -v mock_ | sort | uniq)"

lintRet=0
vetRet=0
testRet=0
#loop through packages and test
for p in $packages
  do
    # golint if it is installed
    if golint 2>/dev/null; then
      echo "linting package $p"
      golint $p/*.go
      lintRet=$lintRet+$?
    fi

    # vet
    echo "running go vet on $p"
    go vet $p/*.go
    vetRet=$vetRet+$?

    # test
    echo "Running tests for $p"

    # make a tmp cover file then copy it to the right location for SublimeGoCoverage
    cover=$p/cover.out
    tmpcover=$(mktemp /tmp/tmp.XXXXXX)

    go test $verboseMode -coverprofile $tmpcover $runOpt "./$p"
    testRet=$testRet+$?

    sed 's/.*\///' $tmpcover > $cover
  done

# fail if any of the tests / vet / lint failed
exit $(($lintRet+$vetRet+$testRet))
