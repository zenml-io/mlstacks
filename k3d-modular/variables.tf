# enable services
variable "enable_container_registry" {
  description = "Enable K3D registry deployment"
  default     = false
}
variable "enable_kubernetes" {
  description = "Enable Kubernetes deployment"
  default     = false
}
variable "enable_kubeflow" {
  description = "Enable Kubeflow deployment"
  default     = true
}
variable "enable_minio" {
  description = "Enable Minio deployment"
  default     = true
}
variable "enable_tekton" {
  description = "Enable Tekton deployment"
  default     = false
}
variable "enable_mlflow" {
  description = "Enable MLflow deployment"
  default     = true
}
variable "enable_kserve" {
  description = "Enable KServe deployment"
  default     = false
}
variable "enable_seldon" {
  description = "Enable Seldon deployment"
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
variable "kserve-secret-name" {
  description = "The Kserve Model Deployer Secret name"
  default     = "zenml-kserve-secret"
  type        = string
}

# variables for creating a ZenML stack configuration file
variable "zenml-version" {
  description = "The version of ZenML being used"
  default     = "0.31.1"
  type        = string
}
