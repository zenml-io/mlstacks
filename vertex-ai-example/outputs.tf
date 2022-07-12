# project number
output "project-number" {
  value = data.google_project.project.number
}

# service account for vertex AI
output "service-account" {
  value = google_service_account.sa.email
}

# output for the GCS bucket
output "gcs-bucket-path" {
  value = google_storage_bucket.artifact-store.name
  description = "The GCS bucket name for storing your artifacts"
}

# outputs for the CloudSQL metadata store
output "metadata-db-host" {
  value = module.metadata_store.instance_ip_address
}
output "metadata-db-connection-name" {
  value = module.metadata_store.instance_connection_name
}
output "metadata-db-username" {
  value = var.metadata-db-username
  sensitive = true
}
output "metadata-db-password" {
  description = "The auto generated default user password if not input password was provided"
  value       = module.metadata_store.generated_user_password
  sensitive   = true
}

# output for container registry
output "container-registry-URI" {
  value = "${local.container_registry.region}.gcr.io/${local.project_id}"
}

# # output for artifact registry repository
# output "artifact-repository-name" {
#   value = local.artifact_repository.enable_container_registry ? google_artifact_registry_repository.artifact-repository[0].name : "not enabled"
#   description = "The artifact registry repository name for storing your images"
# }