# output for the GKE cluster
output "gke-cluster-name" {
  value = module.gke.name
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
output "artifact-repository-name" {
  value = google_artifact_registry_repository.artifact-repository.name
  description = "The artifact registry repository name for storing your images"
}

# outputs for the MLflow tracking server
output "ingress-controller-name" {
  value = module.mlflow.ingress-controller-name
}
output "ingress-controller-namespace" {
  value = module.mlflow.ingress-controller-namespace
}

# output for seldon model deployer
output "seldon-core-workload-namespace" {
  value = kubernetes_namespace.seldon-workloads.metadata[0].name
  description = "The namespace created for hosting your Seldon workloads"
}
output "seldon-prediction-spec" {
  value = module.seldon.ingress-gateway-spec
  sensitive = true
}
  