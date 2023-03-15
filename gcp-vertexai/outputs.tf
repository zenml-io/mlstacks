# project number
output "project-number" {
  value = data.google_project.project.number
}
# project id
output "project-id" {
  value = local.project_id
}

# service account for vertex AI
output "service-account" {
  value = google_service_account.sa.email
}

# output for the GCS bucket
output "gcs-bucket-path" {
  value       = "gs://${google_storage_bucket.artifact-store.name}"
  description = "The GCS bucket name for storing your artifacts"
}

# output for container registry
output "container-registry-URI" {
  value = "${local.container_registry.region}.gcr.io/${local.project_id}"
}

# ingress controller hostname
output "ingress-controller-host" {
  value = var.enable_mlflow ? data.kubernetes_service.mlflow_tracking[0].status.0.load_balancer.0.ingress.0.ip : ""
}

# output for MLflow URI
output "mlflow-tracking-URL" {
  value = var.enable_mlflow ? "${data.kubernetes_service.mlflow_tracking[0].status.0.load_balancer.0.ingress.0.ip}/mlflow/" : "not enabled"
}

# output the name of the stack YAML file created
output "stack-yaml-path" {
  value = var.enable_mlflow ? local_file.stack_file_mlflow[0].filename : local_file.stack_file[0].filename
}

# # output for artifact registry repository
# output "artifact-repository-name" {
#   value = local.artifact_repository.enable_container_registry ? google_artifact_registry_repository.artifact-repository[0].name : "not enabled"
#   description = "The artifact registry repository name for storing your images"
# }