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
"""Enums for mlstacks."""

from enum import Enum


class ComponentTypeEnum(str, Enum):
    """Component type enum."""

    MLOPS_PLATFORM = "mlops_platform"
    ARTIFACT_STORE = "artifact_store"
    ORCHESTRATOR = "orchestrator"
    CONTAINER_REGISTRY = "container_registry"
    DATA_VALIDATOR = "data_validator"
    EXPERIMENT_TRACKER = "experiment_tracker"
    MODEL_REGISTRY = "model_registry"
    MODEL_DEPLOYER = "model_deployer"
    STEP_OPERATOR = "step_operator"
    ALERTER = "alerter"
    FEATURE_STORE = "feature_store"
    ANNOTATOR = "annotator"
    IMAGE_BUILDER = "image_builder"


class ComponentFlavorEnum(str, Enum):
    """Component flavor enum."""

    AWS = "aws"
    GCP = "gcp"
    KUBEFLOW = "kubeflow"
    KUBERNETES = "kubernetes"
    MINIO = "minio"
    MLFLOW = "mlflow"
    S3 = "s3"
    SAGEMAKER = "sagemaker"
    SELDON = "seldon"
    SKYPILOT = "skypilot"
    TEKTON = "tekton"
    VERTEX = "vertex"
    ZENML = "zenml"
    DEFAULT = "default"

    


class DeploymentMethodEnum(str, Enum):
    """Deployment method enum."""

    KUBERNETES = "kubernetes"


class ProviderEnum(str, Enum):
    """Provider enum."""

    AWS = "aws"
    AZURE = "azure"
    GCP = "gcp"
    K3D = "k3d"


class AnalyticsEventsEnum(str, Enum):
    """Analytics events enum."""

    MLSTACKS_DEPLOY = "MLStacks Deploy"
    MLSTACKS_DESTROY = "MLStacks Destroy"
    MLSTACKS_BREAKDOWN = "MLStacks Breakdown"
    MLSTACKS_OUTPUT = "MLStacks Output"
    MLSTACKS_CLEAN = "MLStacks Clean"
    MLSTACKS_SOURCE = "MLStacks Source"
    MLSTACKS_EXCEPTION = "MLStacks Exception"
    MLSTACKS_VERSION = "MLStacks Version"


class SpecTypeEnum(str, Enum):
    """Spec type enum."""

    STACK = "stack"
    COMPONENT = "component"


class StackSpecVersionEnum(int, Enum):
    """Spec version enum."""

    ONE = 1


class ComponentSpecVersionEnum(int, Enum):
    """Spec version enum."""

    ONE = 1
