# create the ZenML Server deployment
resource "kubernetes_namespace" "zen-server" {
  metadata {
    name = "${var.namespace}"
  }
}

resource "helm_release" "zen-server" {

  name             = "zenml-server"
  chart            = "${path.module}/helm"
  namespace        = kubernetes_namespace.zen-server.metadata[0].name


  set {
    name = "zenml.image.tag"
    value = var.zenmlserver_image_tag
    type = "string"
  }
  set {
    name = "zenml.initImage.tag"
    value = var.zenmlinit_image_tag
    type = "string"
  } 
  set {
    name  = "zenml.defaultUsername"
    value = var.username
    type = "string"
  }
  set {
    name  = "zenml.defaultPassword"
    value = var.password
    type = "string"
  }
  set {
    name  = "zenml.deploymentType"
    value = "aws"
    type = "string"
  }
  
  set {
    name = "zenml.ingress.host"
    value = var.ingress_host
    type = "string"
  }
  set {
    name = "zenml.ingress.tls.enabled"
    value = var.ingress_tls
    type = "auto"
  }
  set {
    name = "zenml.ingress.annotations.cert-manager\\.io/cluster-issuer"
    value = var.ingress_tls ? "letsencrypt-staging": ""
    type = "string"
  }
  set {
    name = "zenml.ingress.tls.generateCerts"
    value = var.ingress_tls_generate_certs
    type = "auto"
  }
  set {
    name = "zenml.ingress.tls.secretName"
    value = "${var.ingress_tls_secret_name}"
    type = "string"
  }

  # set parameters for the mysql database
  set {
    name  = "zenml.database.url"
    value = var.database_url
    type = "string"
  }
  set {
    name  = "zenml.database.sslCa"
    value = var.database_ssl_ca
    type = "string"
  }
  set {
    name  = "zenml.database.sslCert"
    value = var.database_ssl_cert
    type = "string"
  }
  set {
    name  = "zenml.database.sslKey"
    value = var.database_ssl_key
    type = "string"
  }
  set {
    name  = "zenml.database.sslVerifyServerCert"
    value = var.database_ssl_verify_server_cert
    type = "auto"
  }
  depends_on = [
    resource.kubernetes_namespace.zen-server
  ]
}

data "kubernetes_secret" "certificates" {
  metadata {
    name = "${var.ingress_tls_secret_name}"
    namespace = "${var.namespace}"
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