# A default (non-aliased) provider configuration for "helm"
provider "helm" {
  kubernetes {
    host                   = "https://${module.gke[0].endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke[0].ca_certificate)
  }
}