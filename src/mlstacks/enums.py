from enum import Enum


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


class DeploymentMethodEnum(str, Enum):
    """Deployment method enum."""

    KUBERNETES = "kubernetes"


class ProviderEnum(str, Enum):
    """Provider enum."""

    AWS = "aws"
    AZURE = "azure"
    GCP = "gcp"
    K3D = "k3d"
