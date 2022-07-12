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
