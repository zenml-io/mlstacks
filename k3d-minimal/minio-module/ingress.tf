# set up the nginx ingress controller and the ingress with basic auth

resource "kubernetes_namespace" "nginx-ns" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "nginx-controller" {
  name       = "nginx-controller"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  set {
    name  = "controller.admissionWebhooks.enabled"
    value = "false"
  }

  # dependency on nginx-ns
  namespace = kubernetes_namespace.nginx-ns.metadata[0].name
}

resource "kubernetes_ingress_v1" "minio-ingress" {
  metadata {
    name = "minio-ingress"
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$1"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path      = "/minio/?(.*)"
          path_type = "Prefix"
          backend {
            service {
              name = "minio-tracking"
              port {
                number = 9000
              }
            }
          }
        }
      }
    }
  }
  depends_on = [
    kubernetes_service.minio-service,
  ]
}