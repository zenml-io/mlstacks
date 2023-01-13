
module "minio_server" {
  source = "../modules/minio-module"

  count = (local.minio.enable || local.mlflow.enable)  ? 1 : 0

  # run only after the eks cluster is set up
  depends_on = [
    k3d_cluster.zenml-cluster,
  ]

  # details about the mlflow deployment
  minio_storage_size        = local.minio.storage_size
  minio_access_key          = var.zenml-minio-store-access-key
  minio_secret_key          = var.zenml-minio-store-secret-key
  ingress_host = "${local.minio.ingress_host_prefix}.${module.nginx-ingress[0].ingress-ip-address}.nip.io"
  ingress_console_host = "${local.minio.ingress_console_host_prefix}.${module.nginx-ingress[0].ingress-ip-address}.nip.io"
  tls_enabled = false
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

  count = (local.minio.enable || local.mlflow.enable)  ? 1 : 0

  name = local.minio.zenml_minio_store_bucket

  depends_on = [
    module.minio_server,
    module.nginx-ingress,
  ]
}
