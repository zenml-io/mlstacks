# A default (non-aliased) provider configuration for "helm"
provider "helm" {
  kubernetes {
    host = (var.enable_container_registry || var.enable_kubeflow ||
      var.enable_tekton || var.enable_kubernetes || var.enable_kserve ||
    var.enable_seldon || var.enable_mlflow || var.enable_minio || var.enable_zenml) ? k3d_cluster.zenml-cluster[0].credentials.0.host : ""
    client_certificate = (var.enable_container_registry || var.enable_kubeflow ||
      var.enable_tekton || var.enable_kubernetes || var.enable_kserve ||
    var.enable_seldon || var.enable_mlflow || var.enable_minio || var.enable_zenml) ? k3d_cluster.zenml-cluster[0].credentials.0.client_certificate : ""
    client_key = (var.enable_container_registry || var.enable_kubeflow ||
      var.enable_tekton || var.enable_kubernetes || var.enable_kserve ||
    var.enable_seldon || var.enable_mlflow || var.enable_minio || var.enable_zenml) ? k3d_cluster.zenml-cluster[0].credentials.0.client_key : ""
    cluster_ca_certificate = (var.enable_container_registry || var.enable_kubeflow ||
      var.enable_tekton || var.enable_kubernetes || var.enable_kserve ||
    var.enable_seldon || var.enable_mlflow || var.enable_minio || var.enable_zenml) ? k3d_cluster.zenml-cluster[0].credentials.0.cluster_ca_certificate : ""
  }
}