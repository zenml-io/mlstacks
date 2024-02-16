#!/bin/bash

#  Copyright (c) ZenML GmbH 2023. All Rights Reserved.
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at:
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
#  or implied. See the License for the specific language governing
#  permissions and limitations under the License.
STACK_YAML_PATH=$1

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
