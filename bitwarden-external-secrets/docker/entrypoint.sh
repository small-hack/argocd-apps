#!/bin/bash

set -e
echo "starting entrypoint script"

echo "configuring the server host: $BW_HOST"
bw config server ${BW_HOST}

echo "logging in with API key"
bw login --apikey

echo "Unlocking the session"
export BW_SESSION=$(bw unlock --passwordenv BW_PASSWORD --raw)

bw unlock --check

echo 'Running `bw server` on port 8087'
bw serve --hostname 0.0.0.0 #--disable-origin-protection
