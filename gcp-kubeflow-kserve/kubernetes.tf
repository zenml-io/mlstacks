# a default (non-aliased) provider configuration for "kubernetes"
# not defining the kubernetes provider throws an error while running the eks module
provider "kubernetes" {
  host                   = "https://${google_container_cluster.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.gke.master_auth.0.cluster_ca_certificate)
}

provider "kubectl" {
  host                   = "https://${google_container_cluster.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.gke.master_auth.0.cluster_ca_certificate)
}