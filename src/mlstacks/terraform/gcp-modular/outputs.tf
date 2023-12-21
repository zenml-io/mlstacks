# if gcs is enabled, set the artifact store outputs to the gcs values
# otherwise, set the artifact store outputs to empty strings
output "artifact_store_id" {
  value = var.enable_artifact_store ? uuid() : ""
}
output "artifact_store_flavor" {
  value = var.enable_artifact_store ? "gcp" : ""
}
output "artifact_store_name" {
  value = var.enable_artifact_store ? "gcs_artifact_store_${random_string.unique.result}" : ""
}
output "artifact_store_configuration" {
  value = var.enable_artifact_store ? jsonencode({
    path = "gs://${google_storage_bucket.artifact-store[0].name}"
  }) : ""
}

# if gcr is enabled, set the container registry outputs to the gcr values
# otherwise, set the container registry outputs to empty strings
output "container_registry_id" {
  value = var.enable_container_registry ? uuid() : ""
}
output "container_registry_flavor" {
  value = var.enable_container_registry ? "gcp" : ""
}
output "container_registry_name" {
  value = var.enable_container_registry ? "gcp_container_registry_${random_string.unique.result}" : ""
}
output "container_registry_configuration" {
  value = var.enable_container_registry ? jsonencode({
    uri = "${local.container_registry.region}.gcr.io/${var.project_id}"
  }) : ""
}

# if kubeflow is enabled, set the orchestrator outputs to the kubeflow values
# if tekton is enabled, set the orchestrator outputs to the tekton values
# if kubernetes is enabled, set the orchestrator outputs to the kubernetes values
# otherwise, set the orchestrator outputs to empty strings
output "orchestrator_id" {
  value = var.enable_orchestrator_kubeflow ? uuid() : var.enable_orchestrator_tekton ? uuid() : var.enable_orchestrator_kubernetes ? uuid() : var.enable_orchestrator_vertex ? uuid() : ""
}
output "orchestrator_flavor" {
  value = var.enable_orchestrator_kubeflow ? "kubeflow" : var.enable_orchestrator_tekton ? "tekton" : var.enable_orchestrator_kubernetes ? "kubernetes" : var.enable_orchestrator_vertex ? "vertex" : ""
}
output "orchestrator_name" {
  value = var.enable_orchestrator_kubeflow ? "gke_kubeflow_orchestrator_${random_string.unique.result}" : var.enable_orchestrator_tekton ? "gke_tekton_orchestrator_${random_string.unique.result}" : var.enable_orchestrator_kubernetes ? "gke_kubernetes_orchestrator_${random_string.unique.result}" : var.enable_orchestrator_vertex ? "vertex_orchestrator_${random_string.unique.result}" : ""
}
output "orchestrator_configuration" {
  value = var.enable_orchestrator_kubeflow ? jsonencode({
    kubernetes_context = "gke_${var.project_id}_${var.region}_${local.prefix}-${local.gke.cluster_name}"
    synchronous        = true
    }) : var.enable_orchestrator_tekton ? jsonencode({
    kubernetes_context = "gke_${var.project_id}_${var.region}_${local.prefix}-${local.gke.cluster_name}"
    }) : var.enable_orchestrator_kubernetes ? jsonencode({
    kubernetes_context = "gke_${var.project_id}_${var.region}_${local.prefix}-${local.gke.cluster_name}"
    synchronous        = true
    }) : var.enable_orchestrator_vertex ? jsonencode({
    project  = var.project_id
    location = var.region
  }) : ""

  depends_on = [
    google_container_cluster.gke
  ]
}

output "step_operator_id" {
  value = var.enable_step_operator_vertex ? uuid() : ""
}
output "step_operator_flavor" {
  value = var.enable_step_operator_vertex ? "vertex" : ""
}
output "step_operator_name" {
  value = var.enable_step_operator_vertex ? "vertex_step_operator_${random_string.unique.result}" : ""
}
output "step_operator_configuration" {
  value = var.enable_step_operator_vertex ? jsonencode({
    project              = var.project_id
    region               = var.region
    service_account_path = local_file.sa_key_file[0].filename
  }) : ""
}

# if mlflow is enabled, set the tracking server outputs to the mlflow values
# otherwise, set the tracking server outputs to empty strings
output "experiment_tracker_id" {
  value = var.enable_experiment_tracker_mlflow ? uuid() : ""
}
output "experiment_tracker_flavor" {
  value = var.enable_experiment_tracker_mlflow ? "mlflow" : ""
}
output "experiment_tracker_name" {
  value = var.enable_experiment_tracker_mlflow ? "gke_mlflow_experiment_tracker_${random_string.unique.result}" : ""
}
output "experiment_tracker_configuration" {
  value = var.enable_experiment_tracker_mlflow ? jsonencode({
    tracking_uri      = module.mlflow[0].mlflow-tracking-URL
    tracking_username = var.mlflow-username
    tracking_password = var.mlflow-password
  }) : ""
}

# if kserve is enabled, set the model deployer outputs to the kserve values
# if seldon is enabled, set the model deployer outputs to the seldon values
# otherwise, set the model deployer outputs to empty strings
output "model_deployer_id" {
  value = var.enable_model_deployer_kserve ? uuid() : var.enable_model_deployer_seldon ? uuid() : ""
}
output "model_deployer_flavor" {
  value = var.enable_model_deployer_kserve ? "kserve" : var.enable_model_deployer_seldon ? "seldon" : ""
}
output "model_deployer_name" {
  value = var.enable_model_deployer_kserve ? "gke_kserve_model_deployer_${random_string.unique.result}" : var.enable_model_deployer_seldon ? "gke_seldon_model_deployer_${random_string.unique.result}" : ""
}
output "model_deployer_configuration" {
  value = var.enable_model_deployer_kserve ? jsonencode({
    kubernetes_context   = "gke_${var.project_id}_${var.region}_${local.prefix}-${local.gke.cluster_name}"
    kubernetes_namespace = local.kserve.workloads_namespace
    base_url             = module.kserve[0].kserve-base-URL
    }) : var.enable_model_deployer_seldon ? jsonencode({
    kubernetes_context   = "gke_${var.project_id}_${var.region}_${local.prefix}-${local.gke.cluster_name}"
    kubernetes_namespace = local.seldon.workloads_namespace
    base_url             = "http://${module.istio[0].ingress-ip-address}:${module.istio[0].ingress-port}"
  }) : ""
}

# project id
output "project-id" {
  value = var.project_id
}

# output for the GKE cluster
output "gke-cluster-name" {
  value = length(google_container_cluster.gke) > 0 ? "${local.prefix}-${local.gke.cluster_name}" : ""
}

# output for the GCS bucket
output "gcs-bucket-path" {
  value       = var.enable_artifact_store ? "gs://${google_storage_bucket.artifact-store[0].name}" : ""
  description = "The GCS bucket path for storing your artifacts"
}


# output for container registry
output "container-registry-URI" {
  value = var.enable_container_registry ? "${local.container_registry.region}.gcr.io/${var.project_id}" : ""
}

# ingress controller hostname (for the zenserver deploy CLI)
output "ingress-controller-host" {
  value = length(module.nginx-ingress) > 0 ? module.nginx-ingress[0].ingress-ip-address : null
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
  value = var.enable_orchestrator_kubeflow ? module.kubeflow-pipelines[0].pipelines-ui-URL : null
}

output "tekton-pipelines-ui-URL" {
  value = var.enable_orchestrator_tekton ? module.tekton-pipelines[0].pipelines-ui-URL : null
}

# outputs for the MLflow tracking server
output "mlflow-tracking-URL" {
  value = var.enable_experiment_tracker_mlflow ? module.mlflow[0].mlflow-tracking-URL : null
}
output "mlflow-bucket" {
  value = (var.enable_experiment_tracker_mlflow && var.mlflow_bucket == "") ? "mlflow-gcs-${random_string.mlflow_bucket_suffix.result}" : ""
}

# output for kserve model deployer
output "kserve-workload-namespace" {
  value       = var.enable_model_deployer_kserve ? local.kserve.workloads_namespace : null
  description = "The namespace created for hosting your Kserve workloads"
}
output "kserve-base-url" {
  value = var.enable_model_deployer_kserve ? module.kserve[0].kserve-base-URL : null
}

# output for seldon model deployer
output "seldon-workload-namespace" {
  value       = var.enable_model_deployer_seldon ? local.seldon.workloads_namespace : null
  description = "The namespace created for hosting your Seldon workloads"
}

output "seldon-base-url" {
  value = var.enable_model_deployer_seldon ? module.istio[0].ingress-ip-address : null
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
