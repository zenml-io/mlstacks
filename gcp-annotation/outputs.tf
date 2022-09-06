# output for the GCS bucket
output "gcs-bucket-path" {
  value       = "gs://${google_storage_bucket.artifact-store.name}"
  description = "The GCS bucket path for storing your artifacts"
}

# output for container registry
output "container-registry-URI" {
  value = "${local.container_registry.region}.gcr.io/${local.project_id}"
}

# output the name of the stack YAML file created
output "stack-yaml-path" {
  value = local_file.stack_file.filename
}
  