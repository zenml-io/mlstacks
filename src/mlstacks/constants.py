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
    "container_registry": ["gcp", "aws", "default"],
    "experiment_tracker": ["mlflow"],
    "orchestrator": [
        "kubeflow",
        "kubernetes",
        "sagemaker",
        "skypilot",
        "tekton",
        "vertex",
    ],
    "mlops_platform": ["zenml"],
    "model_deployer": ["seldon"],
    "step_operator": ["sagemaker", "vertex"],
}
ALLOWED_COMPONENT_TYPES = {
    "aws": {
        "artifact_store": ["s3"],
        "container_registry": ["aws"],
        "experiment_tracker": ["mlflow"],
        "orchestrator": [
            "kubeflow",
            "kubernetes",
            "sagemaker",
            "skypilot",
            "tekton",
        ],
        "mlops_platform": ["zenml"],
        "model_deployer": ["seldon"],
        "step_operator": ["sagemaker"],
    },
    "gcp": {
        "artifact_store": ["gcp"],
        "container_registry": ["gcp"],
        "experiment_tracker": ["mlflow"],
        "orchestrator": [
            "kubeflow",
            "kubernetes",
            "skypilot",
            "tekton",
            "vertex",
        ],
        "mlops_platform": ["zenml"],
        "model_deployer": ["seldon"],
        "step_operator": ["vertex"],
    },
    "k3d": {
        "artifact_store": ["minio"],
        "container_registry": ["default"],
        "experiment_tracker": ["mlflow"],
        "orchestrator": [
            "kubeflow",
            "kubernetes",
            "sagemaker",
            "tekton",
        ],
        "mlops_platform": ["zenml"],
        "model_deployer": ["seldon"],
    },
}

PERMITTED_NAME_REGEX = r"^[a-zA-Z0-9][a-zA-Z0-9_-]*$"
ANALYTICS_OPT_IN_ENV_VARIABLE = "MLSTACKS_ANALYTICS_OPT_IN"

# Shared error messages
INVALID_NAME_ERROR_MESSAGE = (
    "Name must start with an alphanumeric character and can only "
    "contain alphanumeric characters, underscores, and hyphens "
    "thereafter."
)
INVALID_COMPONENT_TYPE_ERROR_MESSAGE = (
    "Artifact Store, Container Registry, Experiment Tracker, Orchestrator,"
    "MLOps Platform, and Model Deployer may be used with aws, gcp, and k3d"
    "providers. Step Operator may only be used with aws and gcp."
)
INVALID_COMPONENT_FLAVOR_ERROR_MESSAGE = (
    "Only certain flavors are allowed for a given provider-component type"
    "combination. For more information, consult the tables for your specified"
    "provider at the MLStacks documentation:"
    "https://mlstacks.zenml.io/stacks/stack-specification."
)
STACK_COMPONENT_PROVIDER_MISMATCH_ERROR_MESSAGE = (
    "Stack provider and component provider mismatch."
)
DEFAULT_REMOTE_STATE_BUCKET_NAME = "zenml-mlstacks-remote-state"
TERRAFORM_CONFIG_BUCKET_REPLACEMENT_STRING = "BUCKETNAMEREPLACEME"
