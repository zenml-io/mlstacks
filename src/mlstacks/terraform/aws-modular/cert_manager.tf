# using the cert-manager module to create a cert-manager deployment
module "cert-manager" {
  source = "../modules/cert-manager-module"
  count  = length(aws_eks_cluster.cluster) > 0 ? 1 : 0

  # run only after the eks cluster is set up
  depends_on = [
    aws_eks_cluster.cluster,
    null_resource.configure-local-kubectl
  ]

  chart_version = local.cert_manager.version
}