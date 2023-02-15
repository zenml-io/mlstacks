#!/bin/bash

eval "$(jq -r '@sh "cluster_name=\(.cluster_name) region=\(.region) profile=\(.profile)"')"

# Initialize the result map
result=()

# Check if the cluster exists
if aws eks describe-cluster --name $cluster_name --region $region --profile $profile > /dev/null 2>&1; then
    # Get the cluster properties as a JSON-encoded string
    properties=$(aws eks describe-cluster --name $cluster_name --region $region --profile $profile --query 'cluster' --output json)
    # Extract the cluster endpoint and the cluster CA certificate from the properties using jq
    endpoint=$(echo $properties | jq -r '.endpoint')
    ca_cert=$(echo $properties | jq -r '.certificateAuthority.data')
    # Encode the endpoint and the CA certificate as a JSON-encoded map
    endpoint_map=$(jq -n --arg endpoint "$endpoint" '{ "endpoint": $endpoint }')
    ca_cert_map=$(jq -n --arg ca_cert "$ca_cert" '{ "ca_certificate": $ca_cert }')
    # Append the endpoint map and the CA certificate map to the result map
    result+=("$endpoint_map")
    result+=("$ca_cert_map")
fi

# Encode the result map as a JSON-encoded string
result_json=$(echo ${result[@]} | jq -s 'add')

# Print the result JSON-encoded map
echo $result_json
