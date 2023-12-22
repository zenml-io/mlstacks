module "istio" {
  source = "../modules/istio-module"

  count = (var.enable_model_deployer_seldon) ? 1 : 0

  depends_on = [
    aws_eks_cluster.cluster,
    null_resource.configure-local-kubectl,
  ]

  chart_version = local.istio.version
}
