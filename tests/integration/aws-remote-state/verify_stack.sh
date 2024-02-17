#!/bin/bash

ENDPOINT_URL="http://localhost:4566"
AWS_REGION="eu-north-1"

# Debugging
echo "Listing S3 buckets:"
aws s3 ls --endpoint-url="$ENDPOINT_URL"
echo "Listing DynamoDB tables:"
aws dynamodb list-tables --endpoint-url="$ENDPOINT_URL" --region "$AWS_REGION"

# Verifying S3 bucket creation
BUCKET_NAME="local-aws-remote-artifact-store"
BUCKET_LIST=$(aws s3 ls --endpoint-url="$ENDPOINT_URL")
if echo "$BUCKET_LIST" | grep -q "$BUCKET_NAME"; then
    echo "S3 bucket '$BUCKET_NAME' creation verification succeeded."
else
    echo "S3 bucket '$BUCKET_NAME' creation verification failed."
    exit 1
fi

# Verifying DynamoDB table creation
TABLE_NAME="local-aws-remote-terraform-state-locks"
TABLE_LIST=$(aws dynamodb list-tables --endpoint-url="$ENDPOINT_URL" --region "$AWS_REGION")
if echo "$TABLE_LIST" | grep -q "$TABLE_NAME"; then
    echo "DynamoDB table '$TABLE_NAME' creation verification succeeded."
else
    echo "DynamoDB table '$TABLE_NAME' creation verification failed."
    exit 1
fi
