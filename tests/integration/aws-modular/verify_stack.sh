#!/bin/bash

STACK_YAML_PATH=$1

# Debugging
echo "Verifying YAML at: $STACK_YAML_PATH"
echo "Contents of the YAML file:"
cat "$STACK_YAML_PATH"

# Verifying artifact_store and orchestrator configurations in the YAML file
if grep -q "artifact_store:" "$STACK_YAML_PATH" && grep -q "flavor: local" "$STACK_YAML_PATH"; then
    echo "Artifact store configuration verification in YAML file succeeded."
else
    echo "Artifact store configuration verification in YAML file failed."
    exit 1
fi

if grep -q "orchestrator:" "$STACK_YAML_PATH" && grep -q "flavor: vm_aws" "$STACK_YAML_PATH" && grep -q "name: aws_skypilot_orchestrator" "$STACK_YAML_PATH"; then
    echo "Skypilot orchestrator configuration verification succeeded."
else
    echo "Skypilot orchestrator configuration verification failed."
    exit 1
fi
