#!/usr/bin/env bash

# -e  Exit immediately if a command exits with a non-zero status
# -u  Treat unset variables as an error when substituting
# -o pipefail  The return value of a pipeline is the status of
#              the last command to exit with a non-zero status

username=$(git config --get user.name | tr '[:upper:] ' '[:lower:]-')
projectname=$(basename -s .git "$(git config --get remote.origin.url)")
spacename="${username}-${projectname}"

# removed namespace if it exists
if devspace list spaces | grep "$spacename" > /dev/null; then
  devspace delete space "$spacename" --cluster development --wait
fi
