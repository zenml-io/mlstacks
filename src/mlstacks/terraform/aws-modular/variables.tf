# enable services
variable "enable_artifact_store" {
  description = "Enable S3 deployment"
  default     = false
}
variable "enable_container_registry" {
  description = "Enable ECR deployment"
  default     = false
}
variable "enable_secrets_manager" {
  description = "Enable Secret Manager deployment"
  default     = false
}
variable "enable_orchestrator_kubeflow" {
  description = "Enable Kubeflow deployment"
  default     = false
}
variable "enable_orchestrator_tekton" {
  description = "Enable Tekton deployment"
  default     = false
}
variable "enable_orchestrator_kubernetes" {
  description = "Enable Kubernetes deployment"
  default     = false
}
variable "enable_orchestrator_skypilot" {
  description = "Enable SkyPilot orchestrator deployment"
  default     = false
}
variable "enable_orchestrator_sagemaker" {
  description = "Enable SageMaker as orchestrator"
  default     = false
}
variable "enable_experiment_tracker_mlflow" {
  description = "Enable MLflow deployment"
  default     = false
}
variable "enable_model_deployer_kserve" {
  description = "Enable KServe deployment"
  default     = false
}
variable "enable_model_deployer_seldon" {
  description = "Enable Seldon deployment"
  default     = false
}
variable "enable_step_operator_sagemaker" {
  description = "Enable SageMaker as step operator"
  default     = false
}
variable "enable_zenml" {
  description = "Enable ZenML deployment"
  default     = false
}

variable "repo_name" {
  description = "The name of the container repository"
  default     = ""
}
variable "bucket_name" {
  description = "The name of the S3 bucket"
  default     = ""
}
variable "region" {
  description = "The region to deploy resources to"
  default     = "eu-west-1"
}

# variables for the MLflow tracking server
variable "mlflow-artifact-S3-access-key" {
  description = "Your AWS access key for using S3 as MLflow artifact store"
  default     = "AKIAJX7X7X7X7X7X7X7X"
  type        = string
}
variable "mlflow-artifact-S3-secret-key" {
  description = "Your AWS secret key for using S3 as MLflow artifact store"
  default     = "JbtUCfSc211GYkmZ5MmBF1"
  type        = string
}
variable "mlflow-username" {
  description = "The username for the MLflow Tracking Server"
  default     = "admin"
  type        = string
}
variable "mlflow-password" {
  description = "The password for the MLflow Tracking Server"
  default     = "supersafepassword"
  type        = string
}
variable "mlflow_bucket" {
  description = "The name of the S3 bucket to use for MLflow artifact store"
  default     = ""
}

# variables for creating a ZenML stack configuration file
variable "zenml-version" {
  description = "The version of ZenML being used"
  default     = "0.50.0"
  type        = string
}

variable "zenml-username" {
  description = "The username for the ZenML Server"
  default     = "default"
  type        = string
}
variable "zenml-password" {
  description = "The password for the ZenML Server"
  default     = "supersafepassword"
  type        = string
}
variable "zenml-database-url" {
  description = "The ZenML Server database URL"
  type        = string
  default     = ""
}

# additional tags defined via CLI
variable "additional_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}
