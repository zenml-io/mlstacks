# create kserve module
module "istio" {
  source = "../modules/istio-module"

  count = (var.enable_kserve || var.enable_seldon) ? 1 : 0

  depends_on = [
    k3d_cluster.zenml-cluster,
  ]

  chart_version = local.istio.version
}
