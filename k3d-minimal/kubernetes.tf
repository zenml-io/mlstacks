# a default (non-aliased) provider configuration for "kubernetes"
# not defining the kubernetes provider throws an error while running the eks module
provider "kubernetes" {
  host  = k3d_cluster.zenml-cluster.credentials.0.host
  client_certificate = k3d_cluster.zenml-cluster.credentials.0.client_certificate
  client_key = k3d_cluster.zenml-cluster.credentials.0.client_key
  cluster_ca_certificate = k3d_cluster.zenml-cluster.credentials.0.cluster_ca_certificate
}

provider "kubectl" {
  host  = k3d_cluster.zenml-cluster.credentials.0.host
  client_certificate = k3d_cluster.zenml-cluster.credentials.0.client_certificate
  client_key = k3d_cluster.zenml-cluster.credentials.0.client_key
  cluster_ca_certificate = k3d_cluster.zenml-cluster.credentials.0.cluster_ca_certificate
}