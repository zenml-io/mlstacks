# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# project id
output "project-id" {
  value = local.project_id
}

# output for the Composer GKE
output "gke-cluster-name" {
  value = google_composer_environment.zenml-airflow.config[0].gke_cluster
}

# The URI of the Apache Airflow Web UI hosted within this environment
output "airflow-uri" {
  value = google_composer_environment.zenml-airflow.config[0].airflow_uri
}

output "dag-gcs-uri" {
  value = google_composer_environment.zenml-airflow.config[0].dag_gcs_prefix
}

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
  