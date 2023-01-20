# create the mlflow tracking server namespace
resource "kubernetes_namespace" "mlflow" {
  metadata {
    name = var.namespace
  }
}

# create the mlflow tracking server deployment
resource "helm_release" "mlflow-tracking" {

  name       = "mlflow-tracking"
  repository = "https://community-charts.github.io/helm-charts"
  chart      = "mlflow"
  version    = var.chart_version

  namespace  = kubernetes_namespace.mlflow.metadata[0].name

  # set ingress 
  set {
    name  = "ingress.enabled"
    value = var.ingress_host != "" ? true : false
    type = "auto"
  }
  set {
    name  = "ingress.className"
    value = var.istio_enabled ? "istio" : "nginx"
    type = "string"
  }
  set {
    name  = "ingress.hosts[0].host"
    value = var.ingress_host
    type = "string"
  }
  set {
    name  = "ingress.hosts[0].paths[0].path"
    value = "/"
    type = "string"
  }
  set {
    name  = "ingress.hosts[0].paths[0].pathType"
    value = "Prefix"
    type = "string"
  }
  dynamic "set" {
    for_each = var.tls_enabled ? [var.ingress_host] : []
    content {
      name  = "ingress.tls[0].hosts[0]"
      value = set.value
      type = "string"
    }
  }
  dynamic "set" {
    for_each = var.tls_enabled ? ["mlflow-tls"] : []
    content {
      name  = "ingress.tls[0].secretName"
      value = set.value
      type = "string"
    }
  }
  set {
    name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/ssl-redirect"
    value = "${var.tls_enabled}"
    type = "string"
  }
  dynamic "set" {
    for_each = var.tls_enabled ? ["letsencrypt-staging"] : []
    content {
      name  = "ingress.annotations.cert-manager\\.io/cluster-issuer"
      value = set.value
      type = "string"
    }
  }
  set {
    name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-realm"
    value = "Authentication Required - mlflow"
    type = "string"
  }
  set {
    name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-secret"
    value = "basic-auth"
    type = "string"
  }
  set {
    name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-type"
    value = "basic"
    type = "string"
  }

  # set proxied access to artifact storage
  set {
    name  = "artifactRoot.proxiedArtifactStorage"
    value = var.artifact_Proxied_Access
    type = "auto"
  }

  # set values for S3 artifact store
  set {
    name  = "artifactRoot.s3.enabled"
    value = var.artifact_S3
    type = "auto"
  }
  set {
    name  = "artifactRoot.s3.bucket"
    value = var.artifact_S3_Bucket
    type = "string"
  }
  set_sensitive {
    name  = "artifactRoot.s3.awsAccessKeyId"
    value = var.artifact_S3_Access_Key
    type = "string"
  }
  set_sensitive {
    name  = "artifactRoot.s3.awsSecretAccessKey"
    value = var.artifact_S3_Secret_Key
    type = "string"
  }
  dynamic "set" {
    for_each = var.artifact_S3_Endpoint_URL != "" ? [var.artifact_S3_Endpoint_URL] : []
    content {
      name  = "extraEnvVars.MLFLOW_S3_ENDPOINT_URL"
      value = set.value
      type = "string"
    }
  }

  # set values for Azure Blob Storage
  set {
    name  = "artifactRoot.azureBlob.enabled"
    value = var.artifact_Azure
    type = "auto"
  }
  set {
    name  = "artifactRoot.azureBlob.storageAccount"
    value = var.artifact_Azure_Storage_Account_Name
    type = "string"
  }
  set {
    name  = "artifactRoot.azureBlob.container"
    value = var.artifact_Azure_Container
    type = "string"
  }
  set_sensitive {
    name  = "artifactRoot.azureBlob.accessKey"
    value = var.artifact_Azure_Access_Key
    type = "string"
  }

  # set values for GCS artifact store
  set {
    name  = "artifactRoot.gcs.enabled"
    value = var.artifact_GCS
    type = "auto"
  }
  set {
    name  = "artifactRoot.gcs.bucket"
    value = var.artifact_GCS_Bucket
    type = "string"
  }
  depends_on = [
    resource.kubernetes_namespace.mlflow
  ]
}