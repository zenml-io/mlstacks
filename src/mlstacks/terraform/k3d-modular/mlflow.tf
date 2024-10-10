# using the mlflow module to create an mlflow deployment
module "mlflow" {
  source = "../modules/mlflow-module"

  count = var.enable_experiment_tracker_mlflow ? 1 : 0

  # run only after the gke cluster and nginx-ingress are set up
  depends_on = [
    k3d_cluster.zenml-cluster,
    module.nginx-ingress,
    module.istio,
    module.minio_server,
  ]

  # details about the mlflow deployment
  chart_version            = local.mlflow.version
  ingress_host             = (var.enable_model_deployer_seldon) ? "${local.mlflow.ingress_host_prefix}.${module.istio[0].ingress-ip-address}.nip.io" : "${local.mlflow.ingress_host_prefix}.${module.nginx-ingress[0].ingress-ip-address}.nip.io"
  tls_enabled              = false
  istio_enabled            = (var.enable_model_deployer_seldon) ? true : false
  htpasswd                 = "${var.mlflow-username}:${htpasswd_password.hash.apr1}"
  artifact_Proxied_Access  = local.mlflow.artifact_Proxied_Access
  artifact_S3              = "true"
  artifact_S3_Bucket       = var.mlflow_minio_bucket == "" ? minio_s3_bucket.mlflow_bucket[0].bucket : var.mlflow_minio_bucket
  artifact_S3_Access_Key   = var.zenml-minio-store-access-key
  artifact_S3_Secret_Key   = var.zenml-minio-store-secret-key
  artifact_S3_Endpoint_URL = module.minio_server[0].artifact_S3_Endpoint_URL
}

resource "htpasswd_password" "hash" {
  password = var.mlflow-password
}

resource "random_string" "mlflow_bucket_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Create a bucket for MLFlow to use
resource "minio_s3_bucket" "mlflow_bucket" {
  count = (var.enable_experiment_tracker_mlflow && var.mlflow_minio_bucket == "") ? 1 : 0

  bucket        = "mlflow-minio-${random_string.mlflow_bucket_suffix.result}"
  force_destroy = true

  depends_on = [
    module.minio_server,
    module.nginx-ingress,
    module.istio,
  ]
}