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

# output for kserve model deployer
output "kserve-workload-namespace" {
  value       = local.kserve.workloads_namespace
  description = "The namespace created for hosting your Kserve workloads"
}
output "kserve-base-url" {
  value = "http://${data.kubernetes_service.kserve_ingress.status.0.load_balancer.0.ingress.0.ip}:${data.kubernetes_service.kserve_ingress.spec.0.port.1.port}"

}

# output the name of the stack YAML file created
output "stack-yaml-path" {
  value = local_file.stack_file.filename
}
  