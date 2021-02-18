#!/bin/bash

set -e
eval "$(/usr/local/bin/envkey-source)"
exec "$@"
