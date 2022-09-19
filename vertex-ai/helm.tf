# A default (non-aliased) provider configuration for "helm"
provider "helm" {
  kubernetes {
    host                   = local.enable_mlflow? "https://${module.gke[0].endpoint}" : ""
    token                  = local.enable_mlflow? data.google_client_config.default.access_token : ""
    cluster_ca_certificate = local.enable_mlflow? base64decode(module.gke[0].ca_certificate) : ""
  }
}