# A default (non-aliased) provider configuration for "helm"
provider "helm" {
  kubernetes {
  host  = "https://${k3d_cluster.zenml-cluster.kube_api.host_ip}:${k3d_cluster.zenml-cluster.kube_api.host_port}"
  token = k3d_cluster.zenml-cluster.token
  }
}