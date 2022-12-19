# set up kubeflow
resource "docker_container" "minio_server" {
  name  = "minio-server-${random_string.cluster_id.result}"
  image = "quay.io/minio/minio"

  env = ["MINIO_ROOT_USER=${var.zenml-minio-store-access-key}", "MINIO_ROOT_PASSWORD=${var.zenml-minio-store-secret-key}"]

  command = ["server", "/data", "--console-address" , ":9001"]
  
  volumes {
    container_path = "/data"
    host_path = "/${var.zenml-local-stores}"
  }
  
  ports {
    internal = "9000"
    external = "9000"
  }

  ports {
    internal = "9001"
    external = "9001"
  }

  networks_advanced {
    name = k3d_cluster.zenml-cluster.network
  }

  depends_on = [
    k3d_cluster.zenml-cluster,
  ]
}

provider "minio" {
  # The Minio server endpoint.
  # NOTE: do NOT add an http:// or https:// prefix!
  # Set the `ssl = true/false` setting instead.
  endpoint = "${local.minio.host}:${local.minio.port}"
  # Specify your minio user access key here.
  access_key = var.zenml-minio-store-access-key
  # Specify your minio user secret key here.
  secret_key = var.zenml-minio-store-secret-key
  # If true, the server will be contacted via https://
  ssl = false
}
# Create a bucket for ZenML to use
resource "minio_bucket" "zenml_bucket" {
  name = "${local.minio.name}"
  count = var.create-buckets ? 1 : 0

  depends_on = [
    docker_container.minio_server,
  ]
}

# Create a bucket for MLFlow to use
resource "minio_bucket" "mlflow_bucket" {
  name = "${local.mlflow.artifact_S3_Bucket}"
  count = var.create-buckets ? 1 : 0

  depends_on = [
    docker_container.minio_server,
  ]
}