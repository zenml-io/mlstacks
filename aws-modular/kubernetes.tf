# a default (non-aliased) provider configuration for "kubernetes"
# not defining the kubernetes provider throws an error while running the eks module
provider "kubernetes" {
  host                   = length(data.aws_eks_cluster.cluster) > 0? data.aws_eks_cluster.cluster.endpoint: ""
  cluster_ca_certificate = length(data.aws_eks_cluster.cluster) > 0? base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data): ""
  token                  = length(data.aws_eks_cluster_auth.cluster) > 0? data.aws_eks_cluster_auth.cluster.token: ""
}

provider "kubectl" {
  host                   = length(data.aws_eks_cluster.cluster) > 0? data.aws_eks_cluster.cluster.endpoint: ""
  cluster_ca_certificate = length(data.aws_eks_cluster.cluster) > 0? base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data): ""
  token                  = length(data.aws_eks_cluster_auth.cluster) > 0? data.aws_eks_cluster_auth.cluster.token: ""
}

# the namespace where zenml will run kubernetes orchestrator workloads
resource "kubernetes_namespace" "k8s-workloads" {
  count = length(module.eks) > 0? 1 : 0
  metadata {
    name = local.eks.workloads_namespace
  }
  depends_on = [
    module.eks,
  ]
}
