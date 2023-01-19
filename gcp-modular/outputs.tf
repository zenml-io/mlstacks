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

# nginx ingress hostname
output "nginx-ingress-hostname" {
  value = length(module.nginx-ingress) > 0 ? module.nginx-ingress[0].ingress-ip-address : null
}

# istio ingress hostname
output "istio-ingress-hostname" {
  value = length(module.istio) > 0 ? module.istio[0].ingress-ip-address : null
}


output "kubeflow-pipelines-ui-URL" {
  value = var.enable_kubeflow ? module.kubeflow-pipelines[0].pipelines-ui-URL : null
}

output "tekton-pipelines-ui-URL" {
  value = var.enable_tekton ? module.tekton-pipelines[0].pipelines-ui-URL : null
}

# outputs for the MLflow tracking server
output "mlflow-tracking-URL" {
  value = var.enable_mlflow ? module.mlflow[0].mlflow-tracking-URL : null
}

# output for kserve model deployer
output "kserve-workload-namespace" {
  value       = var.enable_kserve ? local.kserve.workloads_namespace : null
  description = "The namespace created for hosting your Kserve workloads"
}
output "kserve-base-url" {
  value = var.enable_kserve ? module.kserve[0].kserve-base-URL : null
}

# output for seldon model deployer
output "seldon-workload-namespace" {
  value       = var.enable_seldon ? local.seldon.workloads_namespace : null
  description = "The namespace created for hosting your Seldon workloads"
}

output "seldon-base-url" {
  value = var.enable_seldon ? module.istio[0].ingress-ip-address : null
}

# output the name of the stack YAML file created
output "stack-yaml-path" {
  value = local_file.stack_file.filename
}

# outputs for the ZenML server
output "zenml-url" {
  value = var.enable_zenml ? module.zenml[0].zenml_server_url : null
}
output "zenml-username" {
  value = var.enable_zenml ? module.zenml[0].username : null
}