# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

locals {
  enable_minio = (var.enable_artifact_store || var.enable_experiment_tracker_mlflow)
}
module "minio_server" {
  source = "../modules/minio-module"

  count = local.enable_minio ? 1 : 0

  # run only after the eks cluster is set up
  depends_on = [
    k3d_cluster.zenml-cluster,
    module.istio,
  ]

  # details about the mlflow deployment
  minio_storage_size   = local.minio.storage_size
  minio_access_key     = var.zenml-minio-store-access-key
  minio_secret_key     = var.zenml-minio-store-secret-key
  ingress_host         = (var.enable_model_deployer_kserve || var.enable_model_deployer_seldon) ? "${local.minio.ingress_host_prefix}.${module.istio[0].ingress-ip-address}.nip.io" : "${local.minio.ingress_host_prefix}.${module.nginx-ingress[0].ingress-ip-address}.nip.io"
  ingress_console_host = (var.enable_model_deployer_kserve || var.enable_model_deployer_seldon) ? "${local.minio.ingress_console_host_prefix}.${module.istio[0].ingress-ip-address}.nip.io" : "${local.minio.ingress_console_host_prefix}.${module.nginx-ingress[0].ingress-ip-address}.nip.io"
  tls_enabled          = false
  istio_enabled        = (var.enable_model_deployer_kserve || var.enable_model_deployer_seldon) ? true : false
}

provider "minio" {
  # The Minio server endpoint.
  # NOTE: do NOT add an http:// or https:// prefix!
  # Set the `ssl = true/false` setting instead.
  minio_server = "localhost:9000"
  # Specify your minio user access key here.
  minio_user = var.zenml-minio-store-access-key
  # Specify your minio user secret key here.
  minio_password = var.zenml-minio-store-secret-key
  # If true, the server will be contacted via https://
  minio_ssl = false
}
# Create a bucket for ZenML to use
resource "minio_s3_bucket" "zenml_bucket" {

  count = (var.enable_artifact_store) ? 1 : 0

  bucket        = local.minio.zenml_minio_store_bucket
  force_destroy = true

  depends_on = [
    module.minio_server,
    module.nginx-ingress,
    module.istio,
  ]
}
