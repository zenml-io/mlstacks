# A default (non-aliased) provider configuration for "helm"
provider "helm" {
  kubernetes {
    host                   = (data.external.get_cluster_info.result != null) ? lookup(data.external.get_cluster_info.result, "endpoint", "") : ""
    cluster_ca_certificate = (data.external.get_cluster_info.result != null) ? base64decode(lookup(data.external.get_cluster_info.result, "ca_certificate", "")) : ""
    token                  = (data.external.get_cluster_auth.result != null) ? lookup(data.external.get_cluster_auth.result, "token", "") : ""
  }
}
