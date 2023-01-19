# using the zenml module to create a zenml deployment
module "zenml" {
  source = "../modules/zenml-module"

  count = var.enable_zenml ? 1 : 0

  # run only after the gke cluster, cert-manager and nginx-ingress are set up
  depends_on = [
    module.gke,
    null_resource.configure-local-kubectl,
    module.cert-manager,
    module.nginx-ingress
  ]

  # details about the zenml deployment
  chart_version                   = local.zenml.version
  username                        = var.zenml-username
  password                        = var.zenml-password
  database_url                    = var.zenml-database-url
  database_ssl_ca                 = local.zenml.database_ssl_ca
  database_ssl_cert               = local.zenml.database_ssl_cert
  database_ssl_key                = local.zenml.database_ssl_key
  database_ssl_verify_server_cert = local.zenml.database_ssl_verify_server_cert

  ingress_host          = "${local.zenml.ingress_host_prefix}.${module.nginx-ingress[0].ingress-ip-address}.nip.io"
  ingress_tls           = true
  zenmlserver_image_tag = local.zenml.image_tag
  zenmlinit_image_tag   = local.zenml.image_tag
}
