
module "minio_server" {
  source = "../modules/minio-module"

  # run only after the eks cluster is set up
  depends_on = [
    k3d_cluster.zenml-cluster,
  ]

  # details about the mlflow deployment
  minio_storage_size        = local.minio.storage_size
  minio_access_key          = var.zenml-minio-store-access-key
  minio_secret_key          = var.zenml-minio-store-secret-key
  zenml_minio_store_bucket  = local.minio.zenml_minio_store_bucket
  mlflow_minio_store_bucket = local.minio.mlflow_minio_store_bucket
}

provider "minio" {
  # The Minio server endpoint.
  # NOTE: do NOT add an http:// or https:// prefix!
  # Set the `ssl = true/false` setting instead.
  endpoint = "localhost:9000"
  # Specify your minio user access key here.
  access_key = var.zenml-minio-store-access-key
  # Specify your minio user secret key here.
  secret_key = var.zenml-minio-store-secret-key
  # If true, the server will be contacted via https://
  ssl = false
}
# Create a bucket for ZenML to use
resource "minio_bucket" "zenml_bucket" {
  name = local.minio.zenml_minio_store_bucket

  depends_on = [
    module.minio_server,
  ]
  lifecycle {
    prevent_destroy = false
  }
}

# Create a bucket for MLFlow to use
resource "minio_bucket" "mlflow_bucket" {
  name = local.minio.mlflow_minio_store_bucket

  depends_on = [
    module.minio_server,
  ]
  lifecycle {
    prevent_destroy = false
  }
}