# output for the k3d cluster
output "k3d-cluster-name" {
  value = (var.enable_container_registry || var.enable_kubeflow || 
            var.enable_tekton || var.enable_kubernetes || var.enable_kserve ||
            var.enable_seldon || var.enable_mlflow || var.enable_minio)? k3d_cluster.zenml-cluster[0].name : ""
}

# output for container registry
output "container-registry-URI" {
  value = "k3d-${local.k3d_registry.name}-${random_string.cluster_id.result}.localhost:${local.k3d_registry.port}"
}


# nginx ingress hostname
output "nginx-ingress-hostname" {
  value = length(module.nginx-ingress) > 0 ? module.nginx-ingress[0].ingress-ip-address : null
}

# istio ingress hostname
output "istio-ingress-hostname" {
  value = length(module.istio) > 0 ? module.istio[0].ingress-ip-address : null
}

output "minio-console-URL" {
  value = (var.enable_minio || var.enable_mlflow) ? module.minio_server[0].minio-console-URL : null
}

output "minio-endpoint-URL" {
  value = (var.enable_minio || var.enable_mlflow) ? module.minio_server[0].artifact_S3_Endpoint_URL : null
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
