# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# using the seldon module for creating a 
# seldon + istio deployment
module "seldon" {
  source = "./seldon"

  # run only after the eks cluster is set up
  depends_on = [module.eks]

  # details about the seldon deployment
  seldon_name      = local.seldon.name
  seldon_namespace = local.seldon.namespace

  # details about the cluster
  cluster_endpoint       = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  cluster_token          = data.aws_eks_cluster_auth.cluster.token
}

resource "kubernetes_namespace" "seldon-workloads" {
  metadata {
    name = "zenml-seldon-workloads"
  }
}
