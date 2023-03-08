# a default (non-aliased) provider configuration for "kubernetes"
# not defining the kubernetes provider throws an error while running the eks module
provider "kubernetes" {
  host                   = (data.external.get_cluster_info.result != null) ? data.external.get_cluster_info.result["endpoint"] : ""
  cluster_ca_certificate = (data.external.get_cluster_info.result != null) ? base64decode(data.external.get_cluster_info.result["ca_certificate"]) : ""
  token                  = (data.external.get_cluster_auth.result != null) ? data.external.get_cluster_auth.result["token"] : ""
}

provider "kubectl" {
  host                   = (data.external.get_cluster_info.result != null) ? data.external.get_cluster_info.result["endpoint"] : ""
  cluster_ca_certificate = (data.external.get_cluster_info.result != null) ? base64decode(data.external.get_cluster_info.result["ca_certificate"]) : ""
  token                  = (data.external.get_cluster_auth.result != null) ? data.external.get_cluster_auth.result["token"] : ""
}

# the namespace where zenml will run kubernetes orchestrator workloads
resource "kubernetes_namespace" "k8s-workloads" {
  count = length(aws_eks_cluster.cluster) > 0 ? 1 : 0
  metadata {
    name = local.eks.workloads_namespace
  }
  depends_on = [
    aws_eks_cluster.cluster,
  ]
}
