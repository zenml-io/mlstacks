# Create namespace for minio
resource "kubernetes_namespace" "minio-namespace" {
  metadata {
    name = "zenml-minio"
  }
}

resource "kubernetes_persistent_volume" "minio-pv" {
  metadata {
    name = "minio-pv"
    labels = {
      type = "local"
    }
  }
    spec {
      storage_class_name = "manual"
      capacity = {
        storage = var.minio_storage_size
      }
      access_modes = ["ReadWriteOnce"]
      persistent_volume_source {
        host_path {
          path = "/tmp/miniodata"
        }
      }
    }
  depends_on = [
    kubernetes_namespace.minio-namespace,
  ]
}
# Create persistent volume claim for minio to store data
resource "kubernetes_persistent_volume_claim" "minio-pvc" {
  metadata {
    name      = "minio-server-pvc"
    namespace = "zenml-minio"
  }
  spec {
    storage_class_name = "manual"
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.minio_storage_size
      }
    }
  }
  depends_on = [
    kubernetes_persistent_volume.minio-pv,
  ]
}

# Create minio deployment
resource "kubernetes_deployment" "minio-deployment" {
  metadata {
    name      = "zenml-minio-server"
    namespace = "zenml-minio"
  }
  spec {
    replicas = 1
    strategy {
      type = "Recreate"
    }
    selector {
      match_labels = {
        app = "zenml-minio-server"
      }
    }
    template {
      metadata {
        labels = {
          app = "zenml-minio-server"
        }
      }
      spec {
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = "minio-server-pvc"
          }
        }
        container {
          name  = "zenml-minio-fs"
          image = "quay.io/minio/minio"
          args   = ["server", "/data", "--console-address", ":9001"]
          env {
            name  = "MINIO_ACCESS_KEY"
            value = var.minio_access_key
          }
          env {
            name  = "MINIO_SECRET_KEY"
            value = var.minio_secret_key
          }
          port {
            container_port = 9000
            host_port      = 9000
          }
          port {
            container_port = 9001
            host_port      = 9001
          }
          volume_mount {
            name      = "data"
            mount_path = "/data"
          }
        }
      }
    }
  }
  depends_on = [
    kubernetes_persistent_volume_claim.minio-pvc,
  ]
}

# Create minio service
resource "kubernetes_service" "zenml-minio-service" {
  metadata {
    name      = "zenml-minio-service"
    namespace = "zenml-minio"
  }
  spec {
    selector = {
      app = "zenml-minio-server"
    }
    type = "ClusterIP"
    port {
      name = "minio-server"
      protocol = "TCP"
      port     = 9000
      target_port = 9000
    }
    port {
      name = "minio-console"
      protocol = "TCP"
      port     = 9001
      target_port = 9001
    }
  }
  depends_on = [
    kubernetes_deployment.minio-deployment,
  ]
}

# Create ingress for minio
resource "kubectl_manifest" "zenml-minio-ingress" {
  yaml_body = <<YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: zenml-minio-ingress
  namespace: zenml-minio
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-staging
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - ${var.ingress_host}
      secretName: zenml-minio-tls
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: zenml-minio-service
                port:
                  number: 9000       
      host: ${var.ingress_host}
YAML    
  depends_on = [
    kubernetes_service.zenml-minio-service,
  ]
}

# Create ingress for minio
resource "kubectl_manifest" "zenml-minio-console-ingress" {
  yaml_body = <<YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: zenml-minio-console-ingress
  namespace: zenml-minio
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-staging
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - ${var.ingress_console_host}
      secretName: zenml-minio-tls
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: zenml-minio-service
                port:
                  number: 9001       
      host: ${var.ingress_console_host}
YAML    
  depends_on = [
    kubernetes_service.zenml-minio-service,
  ]
}