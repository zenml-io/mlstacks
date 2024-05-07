# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# project number
output "project-number" {
  value       = data.google_project.project.number
  description = "Project number for the GCP project"
}
# project id
output "project-id" {
  value       = local.project_id
  description = "Project ID for the GCP project"
}

# service account for vertex AI
output "service-account" {
  value       = google_service_account.sa.email
  description = "Service account email address reference"
}

# output for the GCS bucket
output "gcs-bucket-path" {
  value       = "gs://${google_storage_bucket.artifact-store.name}"
  description = "The GCS bucket name for storing your artifacts"
}

# output for container registry
output "container-registry-URI" {
  value       = "${local.container_registry.region}.gcr.io/${local.project_id}"
  description = "The container registry URI for storing your images"
}

# ingress controller hostname
output "ingress-controller-host" {
  value       = var.enable_mlflow ? data.kubernetes_service.mlflow_tracking[0].status.0.load_balancer.0.ingress.0.ip : ""
  description = "The ingress controller hostname for your MLflow tracking server"
}

# output for MLflow URI
output "mlflow-tracking-URL" {
  value       = var.enable_mlflow ? "${data.kubernetes_service.mlflow_tracking[0].status.0.load_balancer.0.ingress.0.ip}/mlflow/" : "not enabled"
  description = "The MLflow tracking server URL"
}

# output the name of the stack YAML file created
output "stack-yaml-path" {
  value       = var.enable_mlflow ? local_file.stack_file_mlflow[0].filename : local_file.stack_file[0].filename
  description = "The path to the stack YAML file created"
}

# # output for artifact registry repository
# output "artifact-repository-name" {
#   value = local.artifact_repository.enable_container_registry ? google_artifact_registry_repository.artifact-repository[0].name : "not enabled"
#   description = "The artifact registry repository name for storing your images"
# }
