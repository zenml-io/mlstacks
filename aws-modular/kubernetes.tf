# a default (non-aliased) provider configuration for "kubernetes"
# not defining the kubernetes provider throws an error while running the eks module
provider "kubernetes" {
  host                   = length(data.external.get_cluster_info.result) > 0? data.external.get_cluster_info.result["endpoint"]: ""
  cluster_ca_certificate = length(data.external.get_cluster_info.result) > 0? base64decode(data.external.get_cluster_info.result["ca_certificate"]): ""
  token                  = length(data.external.get_cluster_auth.result) > 0? data.external.get_cluster_auth.result["token"]: ""
}

provider "kubectl" {
  host                   = length(data.external.get_cluster_info.result) > 0? data.external.get_cluster_info.result["endpoint"]: ""
  cluster_ca_certificate = length(data.external.get_cluster_info.result) > 0? base64decode(data.external.get_cluster_info.result["ca_certificate"]): ""
  token                  = length(data.external.get_cluster_auth.result) > 0? data.external.get_cluster_auth.result["token"]: ""
}

# the namespace where zenml will run kubernetes orchestrator workloads
resource "kubernetes_namespace" "k8s-workloads" {
  count = length(aws_eks_cluster.cluster) > 0? 1 : 0
  metadata {
    name = local.eks.workloads_namespace
  }
  depends_on = [
    aws_eks_cluster.cluster,
  ]
}
