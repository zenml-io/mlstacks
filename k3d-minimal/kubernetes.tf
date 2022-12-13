# a default (non-aliased) provider configuration for "kubernetes"
# not defining the kubernetes provider throws an error while running the eks module
provider "kubernetes" {
  host  = "https://${k3d_cluster.zenml-cluster.kube_api[0].host_ip}:${k3d_cluster.zenml-cluster.kube_api[0].host_port}"
  token = k3d_cluster.zenml-cluster.token
}

provider "kubectl" {
  host  = "https://${k3d_cluster.zenml-cluster.kube_api[0].host_ip}:${k3d_cluster.zenml-cluster.kube_api[0].host_port}"
  token = k3d_cluster.zenml-cluster.token
}