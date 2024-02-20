# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# project id
output "project-id" {
  value = local.project_id
}

# output for the GKE cluster
output "gke-cluster-name" {
  value = module.gke.name
}

# output for the GCS bucket
output "gcs-bucket-path" {
  value       = "gs://${google_storage_bucket.artifact-store.name}"
  description = "The GCS bucket path for storing your artifacts"
}

# # output for container registry
# output "artifact-repository-name" {
#   value = local.artifact_repository.enable_container_registry ? google_artifact_registry_repository.artifact-repository[0].name : "not enabled"
#   description = "The artifact registry repository name for storing your images"
# }

# output for container registry
output "container-registry-URI" {
  value = "${local.container_registry.region}.gcr.io/${local.project_id}"
}

# ingress controller hostname
output "ingress-controller-host" {
  value = data.kubernetes_service.mlflow_tracking.status.0.load_balancer.0.ingress.0.ip
}

# outputs for the MLflow tracking server
output "ingress-controller-name" {
  value = module.mlflow.ingress-controller-name
}
output "ingress-controller-namespace" {
  value = module.mlflow.ingress-controller-namespace
}
output "mlflow-tracking-URL" {
  value = "${data.kubernetes_service.mlflow_tracking.status.0.load_balancer.0.ingress.0.ip}/mlflow/"
}

# output for seldon model deployer
output "seldon-core-workload-namespace" {
  value       = kubernetes_namespace.seldon-workloads.metadata[0].name
  description = "The namespace created for hosting your Seldon workloads"
}
output "seldon-prediction-spec" {
  value     = module.seldon.ingress-gateway-spec
  sensitive = true
}
output "seldon-base-url" {
  value = data.kubernetes_service.seldon_ingress.status.0.load_balancer.0.ingress.0.ip
}

# output the name of the stack YAML file created
output "stack-yaml-path" {
  value = local_file.stack_file.filename
}
  