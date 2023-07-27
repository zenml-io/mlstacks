# a default (non-aliased) provider configuration for "kubernetes"
# not defining the kubernetes provider throws an error while running the eks module
provider "kubernetes" {
  host                   = var.enable_mlflow ? "https://${module.gke[0].endpoint}" : ""
  token                  = var.enable_mlflow ? data.google_client_config.default.access_token : ""
  cluster_ca_certificate = var.enable_mlflow ? base64decode(module.gke[0].ca_certificate) : ""
}

provider "kubectl" {
  host                   = var.enable_mlflow ? "https://${module.gke[0].endpoint}" : ""
  token                  = var.enable_mlflow ? data.google_client_config.default.access_token : ""
  cluster_ca_certificate = var.enable_mlflow ? base64decode(module.gke[0].ca_certificate) : ""
}