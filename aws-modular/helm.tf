# A default (non-aliased) provider configuration for "helm"
provider "helm" {
  kubernetes {
    host                   = length(data.aws_eks_cluster.cluster) > 0? data.aws_eks_cluster.cluster.endpoint: ""
    cluster_ca_certificate = length(data.aws_eks_cluster.cluster) > 0? base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data): ""
    token                  = length(data.aws_eks_cluster_auth.cluster) > 0? data.aws_eks_cluster_auth.cluster.token: ""
  }
}
