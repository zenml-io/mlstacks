# using the cert-manager module to create a cert-manager deployment
module "cert-manager" {
  source = "../modules/cert-manager-module"

  # run only after the gke cluster is set up
  depends_on = [
    k3d_cluster.zenml-cluster,
  ]

  chart_version = local.cert_manager.version
}
