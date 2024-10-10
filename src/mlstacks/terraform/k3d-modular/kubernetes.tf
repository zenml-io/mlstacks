# a default (non-aliased) provider configuration for "kubernetes"
provider "kubernetes" {
  host = (var.enable_container_registry || var.enable_orchestrator_kubeflow ||
    var.enable_orchestrator_tekton || var.enable_orchestrator_kubernetes ||
  var.enable_model_deployer_seldon || var.enable_experiment_tracker_mlflow || var.enable_artifact_store || var.enable_zenml) ? k3d_cluster.zenml-cluster[0].credentials.0.host : ""
  client_certificate = (var.enable_container_registry || var.enable_orchestrator_kubeflow ||
    var.enable_orchestrator_tekton || var.enable_orchestrator_kubernetes ||
  var.enable_model_deployer_seldon || var.enable_experiment_tracker_mlflow || var.enable_artifact_store || var.enable_zenml) ? k3d_cluster.zenml-cluster[0].credentials.0.client_certificate : ""
  client_key = (var.enable_container_registry || var.enable_orchestrator_kubeflow ||
    var.enable_orchestrator_tekton || var.enable_orchestrator_kubernetes ||
  var.enable_model_deployer_seldon || var.enable_experiment_tracker_mlflow || var.enable_artifact_store || var.enable_zenml) ? k3d_cluster.zenml-cluster[0].credentials.0.client_key : ""
  cluster_ca_certificate = (var.enable_container_registry || var.enable_orchestrator_kubeflow ||
    var.enable_orchestrator_tekton || var.enable_orchestrator_kubernetes ||
  var.enable_model_deployer_seldon || var.enable_experiment_tracker_mlflow || var.enable_artifact_store || var.enable_zenml) ? k3d_cluster.zenml-cluster[0].credentials.0.cluster_ca_certificate : ""
}

provider "kubectl" {
  host = (var.enable_container_registry || var.enable_orchestrator_kubeflow ||
    var.enable_orchestrator_tekton || var.enable_orchestrator_kubernetes ||
  var.enable_model_deployer_seldon || var.enable_experiment_tracker_mlflow || var.enable_artifact_store || var.enable_zenml) ? k3d_cluster.zenml-cluster[0].credentials.0.host : ""
  client_certificate = (var.enable_container_registry || var.enable_orchestrator_kubeflow ||
    var.enable_orchestrator_tekton || var.enable_orchestrator_kubernetes ||
  var.enable_model_deployer_seldon || var.enable_experiment_tracker_mlflow || var.enable_artifact_store || var.enable_zenml) ? k3d_cluster.zenml-cluster[0].credentials.0.client_certificate : ""
  client_key = (var.enable_container_registry || var.enable_orchestrator_kubeflow ||
    var.enable_orchestrator_tekton || var.enable_orchestrator_kubernetes ||
  var.enable_model_deployer_seldon || var.enable_experiment_tracker_mlflow || var.enable_artifact_store || var.enable_zenml) ? k3d_cluster.zenml-cluster[0].credentials.0.client_key : ""
  cluster_ca_certificate = (var.enable_container_registry || var.enable_orchestrator_kubeflow ||
    var.enable_orchestrator_tekton || var.enable_orchestrator_kubernetes ||
  var.enable_model_deployer_seldon || var.enable_experiment_tracker_mlflow || var.enable_artifact_store || var.enable_zenml) ? k3d_cluster.zenml-cluster[0].credentials.0.cluster_ca_certificate : ""
}

# the namespace where zenml will run kubernetes orchestrator workloads
resource "kubernetes_namespace" "k8s-workloads" {
  metadata {
    name = local.k3d.workloads_namespace
  }
  depends_on = [
    k3d_cluster.zenml-cluster,
  ]
}