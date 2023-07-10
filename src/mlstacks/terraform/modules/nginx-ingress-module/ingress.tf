# set up the nginx ingress controller
resource "kubernetes_namespace" "nginx-ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "nginx-controller" {
  name       = "nginx-controller"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.chart_version

  # dependency on nginx-ns
  namespace = kubernetes_namespace.nginx-ns.metadata[0].name
  depends_on = [
    kubernetes_namespace.nginx-ns
  ]
}

data "kubernetes_service" "nginx-ingress-controller" {
  metadata {
    name      = "${resource.helm_release.nginx-controller.name}-ingress-nginx-controller"
    namespace = kubernetes_namespace.nginx-ns.metadata[0].name
  }
  depends_on = [
    resource.helm_release.nginx-controller
  ]
}
