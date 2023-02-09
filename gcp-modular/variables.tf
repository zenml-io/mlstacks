# enable services
variable "enable_gcs" {
  description = "Enable GCS deployment"
  default     = false
}
variable "enable_gcr" {
  description = "Enable GCR deployment"
  default     = false
}
variable "enable_secrets_manager" {
  description = "Enable Secret Manager deployment"
  default     = false
}
variable "enable_kubeflow" {
  description = "Enable Kubeflow deployment"
  default     = false
}
variable "enable_tekton" {
  description = "Enable Tekton deployment"
  default     = false
}
variable "enable_mlflow" {
  description = "Enable MLflow deployment"
  default     = false
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

# variables for the MLflow tracking server
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

# variables for creating a ZenML stack configuration file
variable "zenml-version" {
  description = "The version of ZenML being used"
  default     = "0.12.0"
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