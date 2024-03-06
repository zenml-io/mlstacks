# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# using the cert-manager module to create a cert-manager deployment
module "cert-manager" {
  source = "../modules/cert-manager-module"
  count  = length(google_container_cluster.gke) > 0 ? 1 : 0

  # run only after the gke cluster is set up
  depends_on = [
    google_container_cluster.gke,
    null_resource.configure-local-kubectl
  ]

  chart_version = local.cert_manager.version
}
