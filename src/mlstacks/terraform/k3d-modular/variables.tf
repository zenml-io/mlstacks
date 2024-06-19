# enable services
variable "enable_container_registry" {
  description = "Enable K3D registry deployment"
  default     = false
}
variable "enable_orchestrator_kubernetes" {
  description = "Enable Kubernetes deployment"
  default     = false
}
variable "enable_orchestrator_kubeflow" {
  description = "Enable Kubeflow deployment"
  default     = false
}
variable "enable_artifact_store" {
  description = "Enable Minio deployment"
  default     = false
}
variable "enable_orchestrator_tekton" {
  description = "Enable Tekton deployment"
  default     = false
}
variable "enable_experiment_tracker_mlflow" {
  description = "Enable MLflow deployment"
  default     = false
}
variable "enable_model_deployer_seldon" {
  description = "Enable Seldon deployment"
  default     = false
}
variable "enable_model_deployer_huggingface" {
  description = "Enable Huggingface deployment"
  default     = false
}
variable "enable_zenml" {
  description = "Enable ZenML deployment"
  default     = false
}


# variables for the MLflow tracking server and Minio S3 bucket
variable "zenml-minio-store-access-key" {
  description = "Your access key for using Minio artifact store"
  default     = "AKIAJX7X7X7X7X7X7X7X"
  type        = string
}
variable "zenml-minio-store-secret-key" {
  description = "Your secret key for using Minio artifact store"
  default     = "JbtUCfSc211GYkmZ5MmBF1"
  type        = string
}
variable "mlflow_minio_bucket" {
  description = "The name of the Minio bucket to use for MLflow artifact store. If no name is provided, a new bucket will be created."
  default     = ""
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

variable "seldon-secret-name" {
  description = "The Seldon Core Model Deployer Secret name"
  default     = "zenml-seldon-secret"
  type        = string
}

variable "huggingface-secret-name" {
  description = "The Huggingface Model Deployer Secret name"
  default     = "zenml-huggingface-secret"
  type        = string
}

# variables for creating a ZenML stack configuration file
variable "zenml-version" {
  description = "The version of ZenML being used"
  default     = "0.55.2"
  type        = string
}

# additional tags defined via CLI
variable "additional_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}
