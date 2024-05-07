# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# A default (non-aliased) provider configuration for "helm"
provider "helm" {
  kubernetes {
    host                   = (data.external.get_cluster.result != null) ? "https://${lookup(data.external.get_cluster.result, "endpoint", "")}" : ""
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = (data.external.get_cluster.result != null) ? base64decode(lookup(data.external.get_cluster.result, "ca_certificate", "")) : ""
  }
}
