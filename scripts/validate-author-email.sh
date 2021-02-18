#!/bin/bash

AUTHOR_INFO=$(git var GIT_AUTHOR_IDENT) || exit 1
COMMIT_AUTHOR_EMAIL=$(printf '%s\n\n' "${AUTHOR_INFO}" | sed -n 's/^.* <\(.*\)> .*$/\1/p')

if [[ ! "$COMMIT_AUTHOR_EMAIL" =~ .+@hqo.co ]]
then
  echo "Error! Only @hqo.co author email is allowed."
  echo "Use 'git config --global/local user.email johndoe@hqo.co' to set you email."
  exit 1
fi
