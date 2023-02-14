# using the cert-manager module to create a cert-manager deployment
module "cert-manager" {
  source = "../modules/cert-manager-module"
  count = length(module.eks) > 0? 1 : 0

  # run only after the eks cluster is set up
  depends_on = [
    module.eks,
    null_resource.configure-local-kubectl
  ]

  chart_version = local.cert_manager.version
}
