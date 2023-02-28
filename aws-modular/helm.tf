# A default (non-aliased) provider configuration for "helm"
provider "helm" {
  kubernetes {
    host                   = length(data.external.get_cluster_info.result) > 0 ? data.external.get_cluster_info.result["endpoint"] : ""
    cluster_ca_certificate = length(data.external.get_cluster_info.result) > 0 ? base64decode(data.external.get_cluster_info.result["ca_certificate"]) : ""
    token                  = length(data.external.get_cluster_auth.result) > 0 ? data.external.get_cluster_auth.result["token"] : ""
  }
}
