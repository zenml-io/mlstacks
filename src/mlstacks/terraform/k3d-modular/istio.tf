module "istio" {
  source = "../modules/istio-module"

  count = (var.enable_model_deployer_huggingface || var.enable_model_deployer_seldon) ? 1 : 0

  depends_on = [
    k3d_cluster.zenml-cluster,
  ]

  chart_version = local.istio.version
}
