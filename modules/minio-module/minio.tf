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