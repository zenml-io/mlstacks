# enable services
variable "enable_artifact_store" {
  description = "Enable GCS deployment"
  default     = false
}
variable "enable_container_registry" {
  description = "Enable GCR deployment"
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
variable "enable_experiment_tracker_mlflow" {
  description = "Enable MLflow deployment"
  default     = false
}

variable "enable_annotator" {
  description = "Enable Label Studio deployment"
  type        = bool
  default     = true
}

variable "huggingface_token" {
  description = "Huggingface token"
  type        = string
  # sensitive     = true
  default     = ""
}

variable "enable_model_deployer_seldon" {
  description = "Enable Seldon deployment"
  default     = false
}
variable "enable_step_operator_vertex" {
  description = "Enable VertexAI Step Operator"
  default     = false
}
variable "enable_orchestrator_vertex" {
  description = "Enable VertexAI Orchestrator"
  default     = false
}
variable "enable_zenml" {
  description = "Enable ZenML deployment"
  default     = false
}

variable "bucket_name" {
  description = "The name of the GCS bucket"
  default     = ""
}
variable "region" {
  description = "The region to deploy resources to"
  default     = "europe-west1"
}
variable "project_id" {
  description = "The project ID to deploy resources to"
  default     = ""
}


# variables for the MLflow tracking server
variable "mlflow_bucket" {
  description = "The name of the GCS bucket to use for MLflow artifact store"
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

# variables for creating a ZenML stack configuration file
variable "zenml-version" {
  description = "The version of ZenML being used"
  default     = "0.55.2"
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
