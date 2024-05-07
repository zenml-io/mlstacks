# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# create the ZenML Server deployment
resource "kubernetes_namespace" "zen-server" {
  metadata {
    name = var.namespace
  }
}

# pull the ZenML helm chart from github
resource "null_resource" "fetch_chart" {

  triggers = {
    zenml_branch = var.chart_version == "" ? "main" : (length(regexall("^([0-9]+)\\.([0-9]+)\\.([0-9]+)$", var.chart_version)) == 0 ? var.chart_version : "release/${var.chart_version}")
  }

  provisioner "local-exec" {
    command = "git clone --depth 1 --branch ${self.triggers.zenml_branch} https://github.com/zenml-io/zenml.git ${path.root}/helm"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf ${path.root}/helm"
  }
}

resource "local_file" "db_ca_cert" {

  count = (var.database_url != "" && var.database_ssl_ca != "") ? 1 : 0

  source   = var.database_ssl_ca
  filename = "${path.root}/helm/src/zenml/zen_server/deploy/helm/ssl_ca.pem"

  depends_on = [
    null_resource.fetch_chart,
  ]
}

resource "local_file" "db_client_cert" {

  count = (var.database_url != "" && var.database_ssl_cert != "") ? 1 : 0

  source   = var.database_ssl_cert
  filename = "${path.root}/helm/src/zenml/zen_server/deploy/helm/ssl_cert.pem"

  depends_on = [
    null_resource.fetch_chart,
  ]
}

resource "local_file" "db_client_key" {

  count = (var.database_url != "" && var.database_ssl_key != "") ? 1 : 0

  source   = var.database_ssl_key
  filename = "${path.root}/helm/src/zenml/zen_server/deploy/helm/ssl_key.pem"

  depends_on = [
    null_resource.fetch_chart,
  ]
}

resource "helm_release" "zen-server" {

  name      = "zenml-server"
  chart     = "${path.root}/helm/src/zenml/zen_server/deploy/helm"
  namespace = kubernetes_namespace.zen-server.metadata[0].name


  set {
    name  = "zenml.image.tag"
    value = var.zenmlserver_image_tag
    type  = "string"
  }
  set {
    name  = "zenml.initImage.tag"
    value = var.zenmlinit_image_tag
    type  = "string"
  }
  set {
    name  = "zenml.defaultUsername"
    value = var.username
    type  = "string"
  }
  set_sensitive {
    name  = "zenml.defaultPassword"
    value = var.password
    type  = "string"
  }
  set {
    name  = "zenml.deploymentType"
    value = "aws"
    type  = "string"
  }

  set {
    name  = "zenml.ingress.host"
    value = var.ingress_host
    type  = "string"
  }
  set {
    name  = "zenml.ingress.tls.enabled"
    value = var.ingress_tls
    type  = "auto"
  }
  set {
    name  = "zenml.ingress.annotations.cert-manager\\.io/cluster-issuer"
    value = var.ingress_tls ? "letsencrypt-staging" : ""
    type  = "string"
  }
  set {
    name  = "zenml.ingress.tls.generateCerts"
    value = var.ingress_tls_generate_certs
    type  = "auto"
  }
  set {
    name  = "zenml.ingress.tls.secretName"
    value = var.ingress_tls_secret_name
    type  = "string"
  }

  # set parameters for the mysql database
  set_sensitive {
    name  = "zenml.database.url"
    value = var.database_url
    type  = "string"
  }
  set {
    name  = "zenml.database.sslCa"
    value = (var.database_url != "" && var.database_ssl_ca != "") ? "ssl_ca.pem" : ""
    type  = "string"
  }
  set {
    name  = "zenml.database.sslCert"
    value = (var.database_url != "" && var.database_ssl_cert != "") ? "ssl_cert.pem" : ""
    type  = "string"
  }
  set {
    name  = "zenml.database.sslKey"
    value = (var.database_url != "" && var.database_ssl_key != "") ? "ssl_key.pem" : ""
    type  = "string"
  }
  set {
    name  = "zenml.database.sslVerifyServerCert"
    value = var.database_ssl_verify_server_cert
    type  = "auto"
  }
  depends_on = [
    null_resource.fetch_chart,
    local_file.db_ca_cert,
    local_file.db_client_cert,
    local_file.db_client_key,
    resource.kubernetes_namespace.zen-server
  ]
}

data "kubernetes_secret" "certificates" {
  metadata {
    name      = var.ingress_tls_secret_name
    namespace = var.namespace
  }
  binary_data = {
    "tls.crt" = ""
    "tls.key" = ""
    "ca.crt"  = ""
  }

  depends_on = [
    helm_release.zen-server
  ]
}
