# A default (non-aliased) provider configuration for "helm"
provider "helm" {
  kubernetes {
    host                   = length(data.google_container_cluster.my_cluster) > 0? "https://${data.google_container_cluster.my_cluster.endpoint}": ""
    token                  = length(data.google_container_cluster.my_cluster) > 0? data.google_client_config.default.access_token: ""
    cluster_ca_certificate = length(data.google_container_cluster.my_cluster) > 0? base64decode(data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate): ""
  }
}