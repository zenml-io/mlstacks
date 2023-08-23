#!/bin/bash

# Read the input JSON object
eval "$(jq -r '@sh "HOSTNAME=\(.hostname)"')"

# Run the dig command and get the first IP address
IP=$(dig +short $HOSTNAME | head -n 1)

# Return the IP address as a JSON object
jq -n --arg ip "$IP" '{"ip":$ip}'
