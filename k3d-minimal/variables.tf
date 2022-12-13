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

# variables for creating a ZenML stack configuration file
variable "zenml-version" {
  description = "The version of ZenML being used"
  default     = "0.30.0"
  type        = string
}