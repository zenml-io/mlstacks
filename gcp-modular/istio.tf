# create kserve module
module "istio" {
  source = "../modules/istio-module"

  count = (var.enable_kserve || var.enable_seldon) ? 1 : 0

  depends_on = [
    module.gke,
    null_resource.configure-local-kubectl,
  ]

  chart_version = local.istio.version
}
