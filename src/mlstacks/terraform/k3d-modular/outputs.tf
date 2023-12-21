# if minio is enabled, set the artifact store outputs to the minio values
# otherwise, set the artifact store outputs to empty strings
output "artifact_store_id" {
  value = var.enable_artifact_store ? uuid() : ""
}
output "artifact_store_flavor" {
  value = var.enable_artifact_store ? "s3" : ""
}
output "artifact_store_name" {
  value = var.enable_artifact_store ? "k3d-minio-${random_string.cluster_id.result}" : ""
}
output "artifact_store_configuration" {
  value = var.enable_artifact_store ? jsonencode({
    path          = "s3://${local.minio.zenml_minio_store_bucket}"
    key           = "${var.zenml-minio-store-access-key}"
    secret        = "${var.zenml-minio-store-secret-key}"
    client_kwargs = "{\"endpoint_url\":\"${module.minio_server[0].artifact_S3_Endpoint_URL}\", \"region_name\":\"us-east-1\"}"
  }) : ""
}

# if container registry is enabled, set the container registry outputs to the k3d values
# otherwise, set the container registry outputs to empty strings
output "container_registry_id" {
  value = (var.enable_container_registry || var.enable_orchestrator_kubeflow ||
    var.enable_orchestrator_tekton || var.enable_orchestrator_kubernetes ||
  var.enable_model_deployer_seldon || var.enable_experiment_tracker_mlflow || var.enable_artifact_store || var.enable_zenml) ? uuid() : ""
}
output "container_registry_flavor" {
  value = (var.enable_container_registry || var.enable_orchestrator_kubeflow ||
    var.enable_orchestrator_tekton || var.enable_orchestrator_kubernetes ||
  var.enable_model_deployer_seldon || var.enable_experiment_tracker_mlflow || var.enable_artifact_store || var.enable_zenml) ? "default" : ""
}
output "container_registry_name" {
  value = (var.enable_container_registry || var.enable_orchestrator_kubeflow ||
    var.enable_orchestrator_tekton || var.enable_orchestrator_kubernetes ||
  var.enable_model_deployer_seldon || var.enable_experiment_tracker_mlflow || var.enable_artifact_store || var.enable_zenml) ? "k3d-${local.k3d_registry.name}-${random_string.cluster_id.result}" : ""
}
output "container_registry_configuration" {
  value = (var.enable_container_registry || var.enable_orchestrator_kubeflow ||
    var.enable_orchestrator_tekton || var.enable_orchestrator_kubernetes ||
    var.enable_model_deployer_seldon || var.enable_experiment_tracker_mlflow || var.enable_artifact_store || var.enable_zenml) ? jsonencode({
      uri = "k3d-${local.k3d_registry.name}-${random_string.cluster_id.result}.localhost:${local.k3d_registry.port}"
  }) : ""
}

# if kubeflow is enabled, set the orchestrator outputs to the kubeflow values
# if kubernetes is enabled, set the orchestrator outputs to the kubernetes values
# if tekton is enabled, set the orchestrator outputs to the tekton values
# otherwise, set the orchestrator outputs to empty strings
output "orchestrator_id" {
  value = var.enable_orchestrator_kubeflow || var.enable_orchestrator_kubernetes || var.enable_orchestrator_tekton ? uuid() : ""
}
output "orchestrator_flavor" {
  value = var.enable_orchestrator_kubeflow ? "kubeflow" : var.enable_orchestrator_kubernetes ? "kubernetes" : var.enable_orchestrator_tekton ? "tekton" : ""
}
output "orchestrator_name" {
  value = var.enable_orchestrator_kubeflow ? "k3d-kubeflow-${random_string.cluster_id.result}" : var.enable_orchestrator_kubernetes ? "k3d-kubernetes-${random_string.cluster_id.result}" : var.enable_orchestrator_tekton ? "k3d-tekton-${random_string.cluster_id.result}" : ""
}
output "orchestrator_configuration" {
  value = var.enable_orchestrator_kubeflow ? jsonencode({
    kubernetes_context = "k3d-${k3d_cluster.zenml-cluster[0].name}"
    synchronous        = true
    local              = true
    }) : var.enable_orchestrator_kubernetes ? jsonencode({
    kubernetes_context   = "k3d-${k3d_cluster.zenml-cluster[0].name}"
    synchronous          = true
    kubernetes_namespace = local.k3d.workloads_namespace
    local                = true
    }) : var.enable_orchestrator_tekton ? jsonencode({
    kubernetes_context   = "k3d-${k3d_cluster.zenml-cluster[0].name}"
    kubernetes_namespace = local.tekton.workloads_namespace
    local                = true
  }) : ""
}

# if mlflow is enabled, set the experiment_tracker outputs to the mlflow values
# otherwise, set the experiment_tracker outputs to empty strings
output "experiment_tracker_id" {
  value = var.enable_experiment_tracker_mlflow ? uuid() : ""
}
output "experiment_tracker_flavor" {
  value = var.enable_experiment_tracker_mlflow ? "mlflow" : ""
}
output "experiment_tracker_name" {
  value = var.enable_experiment_tracker_mlflow ? "k3d-mlflow-${random_string.cluster_id.result}" : ""
}
output "experiment_tracker_configuration" {
  value = var.enable_experiment_tracker_mlflow ? jsonencode({
    tracking_uri      = module.mlflow[0].mlflow-tracking-URL
    tracking_username = var.mlflow-username
    tracking_password = var.mlflow-password
  }) : ""
}

# if seldon is enabled, set the model_deployer outputs to the seldon values
# otherwise, set the model_deployer outputs to empty strings
output "model_deployer_id" {
  value = var.enable_model_deployer_seldon ? uuid() : ""
}
output "model_deployer_flavor" {
  value = var.enable_model_deployer_seldon ? "seldon" : ""
}
output "model_deployer_name" {
  value = var.enable_model_deployer_seldon ? "k3d-seldon-${random_string.cluster_id.result}" : ""
}
output "model_deployer_configuration" {
  value = var.enable_model_deployer_seldon ? jsonencode({
    kubernetes_context   = "k3d-${k3d_cluster.zenml-cluster[0].name}"
    kubernetes_namespace = local.seldon.workloads_namespace
    base_url             = "http://${module.istio[0].ingress-ip-address}:${module.istio[0].ingress-port}"
    }) : ""
}

# output for the k3d cluster
output "k3d-cluster-name" {
  value = (var.enable_container_registry || var.enable_orchestrator_kubeflow ||
    var.enable_orchestrator_tekton || var.enable_orchestrator_kubernetes ||
  var.enable_model_deployer_seldon || var.enable_experiment_tracker_mlflow || var.enable_artifact_store || var.enable_zenml) ? k3d_cluster.zenml-cluster[0].name : ""
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
  value = (var.enable_artifact_store || var.enable_experiment_tracker_mlflow) ? module.minio_server[0].minio-console-URL : null
}
output "minio-endpoint-URL" {
  value = (var.enable_artifact_store || var.enable_experiment_tracker_mlflow) ? module.minio_server[0].artifact_S3_Endpoint_URL : null
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
  value = (var.enable_experiment_tracker_mlflow && var.mlflow_minio_bucket == "") ? "mlflow-minio-${random_string.mlflow_bucket_suffix.result}" : ""
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
