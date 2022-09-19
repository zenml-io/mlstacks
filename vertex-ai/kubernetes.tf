# a default (non-aliased) provider configuration for "kubernetes"
# not defining the kubernetes provider throws an error while running the eks module
provider "kubernetes" {
  host                   = local.enable_mlflow? "https://${module.gke[0].endpoint}" : ""
  token                  = local.enable_mlflow? data.google_client_config.default.access_token : ""
  cluster_ca_certificate = local.enable_mlflow? base64decode(module.gke[0].ca_certificate) : ""
}

provider "kubectl" {
  host                   = local.enable_mlflow? "https://${module.gke[0].endpoint}" : ""
  token                  = local.enable_mlflow? data.google_client_config.default.access_token : ""
  cluster_ca_certificate = local.enable_mlflow? base64decode(module.gke[0].ca_certificate) : ""
}