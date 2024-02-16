#!/bin/bash

ENDPOINT_URL="http://localhost:4566"
AWS_REGION="eu-north-1"

# Verifying S3 bucket creation
BUCKET_NAME="remote-localstack-artifact-store"
if aws s3 ls --endpoint-url="$ENDPOINT_URL" | grep -q "$BUCKET_NAME"; then
    echo "S3 bucket '$BUCKET_NAME' creation verification succeeded."
else
    echo "S3 bucket '$BUCKET_NAME' creation verification failed."
    exit 1
fi

# Verifying DynamoDB table creation
TABLE_NAME="remote-localstack-terraform-state-locks"
if aws dynamodb list-tables --endpoint-url="$ENDPOINT_URL" --region "$AWS_REGION" | grep -q "$TABLE_NAME"; then
    echo "DynamoDB table '$TABLE_NAME' creation verification succeeded."
else
    echo "DynamoDB table '$TABLE_NAME' creation verification failed."
    exit 1
fi