#!/bin/bash

eval "$(jq -r '@sh "cluster_name=\(.cluster_name) region=\(.region)"')"
# cluster_name="zenhacks-cluster"
# region="us-east-1"

# Initialize the result map
result=()

# Check if the cluster exists
if aws eks describe-cluster --name $cluster_name --region $region > /dev/null 2>&1; then
    token=$(aws eks get-token --cluster-name $cluster_name --region $region --output json | jq -r '.status.token')
    # Encode the endpoint, the CA certificate, and the token as a JSON-encoded map
    token_map=$(jq -n --arg token "$token" '{ "token": $token }')
    # Append the token map to the result map
    result+=("$token_map")
fi

# Encode the result map as a JSON-encoded string
result_json=$(echo ${result[@]} | jq -s 'add')

# Print the result JSON-encoded map
echo $result_json
