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

# variables for creating a ZenML stack configuration file
variable "zenml-version" {
  description = "The version of ZenML being used"
  default     = "0.12.0"
  type        = string
}

# additional tags defined via CLI
variable "additional_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}
