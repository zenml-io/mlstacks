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
"""MLStacks constants."""

# enum for deployment types
# deployment_type.KUBERNETES = "KUBERNETES"
MLSTACKS_PACKAGE_NAME = "mlstacks"
MLSTACKS_INITIALIZATION_FILE_FLAG = "IGNORE_ME"
MLSTACKS_STACK_COMPONENT_FLAGS = [
    "artifact_store",
    "container_registry",
    "experiment_tracker",  # takes flavor
    "orchestrator",  # takes flavor
    "mlops_platform",  # takes flavor
    "model_deployer",  # takes flavor
    "step_operator",  # takes flavor
]
ALLOWED_FLAVORS = {
    "artifact_store": ["s3", "gcp", "minio"],
    "container_registry": ["gcp", "aws"],
    "experiment_tracker": ["mlflow"],
    "orchestrator": [
        "kubernetes",
        "kubeflow",
        "tekton",
        "sagemaker",
        "vertex",
    ],
    "mlops_platform": ["zenml"],
    "model_deployer": ["seldon", "kserve"],
    "step_operator": ["sagemaker", "vertex"],
}
