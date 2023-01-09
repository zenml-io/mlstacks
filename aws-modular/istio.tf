# create kserve module
module "istio" {
  source = "../modules/istio-module"

  count = (local.kserve.enable || local.seldon.enable) ? 1 : 0

  depends_on = [
    module.eks,
    null_resource.configure-local-kubectl,
  ]

  chart_version = local.istio.version
}
