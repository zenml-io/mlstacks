"""Component model."""

from enum import Enum
from typing import Dict, Optional

from pydantic import BaseModel

from mlstacks.models.stack import ProviderEnum


class ComponentMetadata(BaseModel):
    """Component metadata model.

    Attributes:
        region: The region where the component will be deployed.
        config: The configuration for the component.
        tags: The tags for the component.
        environment_variables: The environment variables for the component.
    """

    region: str
    config: Optional[Dict[str, str]]
    tags: Optional[Dict[str, str]]
    environment_variables: Optional[Dict[str, str]]


class ComponentTypeEnum(str, Enum):
    """Component type enum."""

    MLOPS_PLATFORM = "mlops_platform"
    ARTIFACT_STORE = "artifact_store"
    ORCHESTRATOR = "orchestrator"
    CONTAINER_REGISTRY = "container_registry"
    SECRETS_MANAGER = "secrets_manager"
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

    ZENML = "zenml"
    MLFLOW = "mlflow"
    KUBEFLOW = "kubeflow"
    KSERVE = "kserve"
    KUBERNETES = "kubernetes"
    S3 = "s3"
    SAGEMAKER = "sagemaker"
    SELDON = "seldon"
    TEKTON = "tekton"


class Component(BaseModel):
    """Component model.

    Attributes:
        spec_version: The version of the component spec.
        spec_type: The type of the component spec.
        component_type: The type of the component.
        name: The name of the component.
        provider: The provider of the component.
        metadata: The metadata of the component.
    """

    spec_version: int = 1
    spec_type: str = "component"
    component_type: ComponentTypeEnum
    component_flavor: ComponentFlavorEnum
    name: str
    provider: ProviderEnum
    metadata: ComponentMetadata
