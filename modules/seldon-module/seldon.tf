# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# creating the namespace for the seldon deployment
resource "kubernetes_namespace" "seldon-ns" {
  metadata {
    name = var.namespace
  }
}

# creating the seldon deployment
resource "helm_release" "seldon" {

  name       = "seldon-core"
  repository = "https://storage.googleapis.com/seldon-charts"
  chart      = "seldon-core-operator"
  version    = var.chart_version

  # dependency on seldon-ns
  namespace = kubernetes_namespace.seldon-ns.metadata[0].name

  # values derived from the zenml seldon-core example at
  # https://github.com/zenml-io/zenml/blob/main/examples/seldon_deployment/README.md#installing-seldon-core-eg-in-an-eks-cluster
  set {
    name  = "usageMetrics.enabled"
    value = "true"
  }

  set {
    name  = "istio.gateway"
    value = "${var.namespace}/${var.istio_gateway_name}"
  }

  set {
    name  = "istio.enabled"
    value = "true"
  }

  depends_on = [
    resource.kubernetes_namespace.seldon-ns
  ]
}
