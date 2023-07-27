# A default (non-aliased) provider configuration for "helm"
provider "helm" {
  kubernetes {
    host                   = var.enable_mlflow ? "https://${module.gke[0].endpoint}" : ""
    token                  = var.enable_mlflow ? data.google_client_config.default.access_token : ""
    cluster_ca_certificate = var.enable_mlflow ? base64decode(module.gke[0].ca_certificate) : ""
  }
}