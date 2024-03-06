# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# create kserve module
module "istio" {
  source = "../modules/istio-module"

  count = (var.enable_model_deployer_kserve || var.enable_model_deployer_seldon) ? 1 : 0

  depends_on = [
    google_container_cluster.gke,
    null_resource.configure-local-kubectl,
  ]

  chart_version = local.istio.version
}
