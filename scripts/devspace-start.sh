#!/usr/bin/env bash

# -e  Exit immediately if a command exits with a non-zero status
# -u  Treat unset variables as an error when substituting
# -o pipefail  The return value of a pipeline is the status of
#              the last command to exit with a non-zero status

username=$(git config --get user.name | tr '[:upper:] ' '[:lower:]-')
projectname=$(basename -s .git "$(git config --get remote.origin.url)")
spacename="${username}-${projectname}"
profile="$1"

# create the namespace if it does exist
until devspace list spaces | grep "$spacename" > /dev/null
do
    devspace create space "$spacename" --cluster development
done

# start environment
devspace dev -p "$profile" -n "$spacename" --switch-context --wait --no-warn
