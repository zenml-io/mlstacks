# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

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
  # dependency on nginx-ns
  namespace = kubernetes_namespace.nginx-ns.metadata[0].name
}

resource "kubernetes_ingress_v1" "mlflow-ingress" {
  metadata {
    name = "mlflow-ingress"
    annotations = {
      "nginx.ingress.kubernetes.io/auth-type"      = "basic"
      "nginx.ingress.kubernetes.io/auth-secret"    = "basic-auth"
      "nginx.ingress.kubernetes.io/auth-realm"     = "Authentication Required - mlflow"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$1"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path      = "/mlflow/?(.*)"
          path_type = "Prefix"
          backend {
            service {
              name = "mlflow-tracking"
              port {
                number = 5000
              }
            }
          }
        }
      }
    }
  }
}
