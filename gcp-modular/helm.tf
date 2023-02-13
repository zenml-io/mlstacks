# A default (non-aliased) provider configuration for "helm"
provider "helm" {
  kubernetes {
    host                   = (var.enable_kubeflow || var.enable_tekton || var.enable_kubernetes || 
                                var.enable_kserve || var.enable_seldon || var.enable_mlflow ||
                                var.enable_zenml)? "https://${module.gke[0].endpoint}" : ""
    token                  = (var.enable_kubeflow || var.enable_tekton || var.enable_kubernetes || 
                                var.enable_kserve || var.enable_seldon || var.enable_mlflow ||
                                var.enable_zenml)? data.google_client_config.default.access_token : ""
    cluster_ca_certificate = (var.enable_kubeflow || var.enable_tekton || var.enable_kubernetes || 
                                var.enable_kserve || var.enable_seldon || var.enable_mlflow ||
                                var.enable_zenml)? base64decode(module.gke[0].ca_certificate) : ""
  }
}