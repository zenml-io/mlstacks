# A default (non-aliased) provider configuration for "helm"
provider "helm" {
  kubernetes {
    host                   = length(data.external.get_cluster.result) > 0 ? data.external.get_cluster.result["endpoint"] : ""
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = length(data.external.get_cluster.result) > 0 ? base64decode(data.external.get_cluster.result["ca_certificate"]) : ""
  }
}