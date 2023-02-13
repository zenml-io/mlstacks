# if gcs is enabled, set the artifact store outputs to the gcs values
# otherwise, set the artifact store outputs to empty strings
output "artifact_store_id" {
  value = var.enable_gcs ? uuid() : ""
}
output "artifact_store_flavor" {
  value = var.enable_gcs ? "gcs" : ""
}
output "artifact_store_name" {
  value = var.enable_gcs ? "gcs_artifact_store" : ""
}
output "artifact_store_configuration" {
  value = var.enable_gcs ? jsonencode({
    path = "gs://${google_storage_bucket.artifact-store[0].name}"
  }) : ""
}

# if gcr is enabled, set the container registry outputs to the gcr values
# otherwise, set the container registry outputs to empty strings
output "container_registry_id" {
  value = var.enable_gcr ? uuid() : ""
}
output "container_registry_flavor" {
  value = var.enable_gcr ? "gcp" : ""
}
output "container_registry_name" {
  value = var.enable_gcr ? "gcp_container_registry" : ""
}
output "container_registry_configuration" {
  value = var.enable_gcr ? jsonencode({
    uri = "${local.container_registry.region}.gcr.io/${local.project_id}"
  }) : ""
}

# if kubeflow is enabled, set the orchestrator outputs to the kubeflow values
# if tekton is enabled, set the orchestrator outputs to the tekton values
# if kubernetes is enabled, set the orchestrator outputs to the kubernetes values
# otherwise, set the orchestrator outputs to empty strings
output "orchestrator_id" {
  value = var.enable_kubeflow ? uuid() : var.enable_tekton ? uuid() : var.enable_kubernetes ? uuid() : ""
}
output "orchestrator_flavor" {
  value = var.enable_kubeflow ? "kubeflow" : var.enable_tekton ? "tekton" :  var.enable_kubernetes ? "kubernetes" : ""
}
output "orchestrator_name" {
  value = var.enable_kubeflow ? "gke_kubeflow_orchestrator" : var.enable_tekton ? "gke_tekton_orchestrator" : var.enable_kubernetes ? "gke_kubernetes_orchestrator" : ""
}
output "orchestrator_configuration" {
  value = var.enable_kubeflow ? jsonencode({
    kubernetes_context = "gke_${local.project_id}_${local.region}_${module.gke[0].name}"
    synchronous        = true
  }) : var.enable_tekton ? jsonencode({
    kubernetes_context = "gke_${local.project_id}_${local.region}_${module.gke[0].name}"
  }) : var.enable_kubernetes ? jsonencode({
    kubernetes_context = "gke_${local.project_id}_${local.region}_${module.gke[0].name}"
    synchronous        = true
  }) : ""
}

# if mlflow is enabled, set the tracking server outputs to the mlflow values
# otherwise, set the tracking server outputs to empty strings
output "experiment_tracker_id" {
  value = var.enable_mlflow ? uuid() : ""
}
output "experiment_tracker_flavor" {
  value = var.enable_mlflow ? "mlflow" : ""
}
output "experiment_tracker_name" {
  value = var.enable_mlflow ? "gke_mlflow_experiment_tracker" : ""
}
output "experiment_tracker_configuration" {
  value = var.enable_mlflow ? jsonencode({
    tracking_uri       = module.mlflow[0].mlflow-tracking-URL
    tracking_username  = var.mlflow-username
    tracking_password  = var.mlflow-password
  }) : ""
}

# if secrets manager is enabled, set the secrets manager outputs to the secrets manager values
# otherwise, set the secrets manager outputs to empty strings
output "secrets_manager_id" {
  value = var.enable_secrets_manager ? uuid() : ""
}
output "secrets_manager_flavor" {
  value = var.enable_secrets_manager ? "gcp" : ""
}
output "secrets_manager_name" {
  value = var.enable_secrets_manager ? "gcp_secrets_manager" : ""
}
output "secrets_manager_configuration" {
  value = var.enable_secrets_manager ? jsonencode({
    project_id = local.project_id
  }) : ""
}

# if kserve is enabled, set the model deployer outputs to the kserve values
# if seldon is enabled, set the model deployer outputs to the seldon values
# otherwise, set the model deployer outputs to empty strings
output "model_deployer_id" {
  value = var.enable_kserve ? uuid() : var.enable_seldon ? uuid() : ""
}
output "model_deployer_flavor" {
  value = var.enable_kserve ? "kserve" : var.enable_seldon ? "seldon" : ""
}
output "model_deployer_name" {
  value = var.enable_kserve ? "gke_kserve_model_deployer" : var.enable_seldon ? "gke_seldon_model_deployer" : ""
}
output "model_deployer_configuration" {
  value = var.enable_kserve ? jsonencode({
    kubernetes_context = "gke_${local.project_id}_${local.region}_${module.gke[0].name}"
    kubernetes_namespace = local.kserve.workloads_namespace
    base_url = module.kserve[0].kserve-base-URL
  }) : var.enable_seldon ? jsonencode({
    kubernetes_context = "gke_${local.project_id}_${local.region}_${module.gke[0].name}"
    kubernetes_namespace = local.seldon.workloads_namespace
    base_url = "http://${module.istio[0].ingress-ip-address}:${module.istio[0].ingress-port}"
  }) : ""
}

# project id
output "project-id" {
  value = local.project_id
}

# output for the GKE cluster
output "gke-cluster-name" {
  value = module.gke[0].name
}

# output for the GCS bucket
output "gcs-bucket-path" {
  value       = "gs://${google_storage_bucket.artifact-store[0].name}"
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