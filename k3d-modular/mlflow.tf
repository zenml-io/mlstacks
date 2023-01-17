# using the mlflow module to create an mlflow deployment
module "mlflow" {
  source = "../modules/mlflow-module"

  count = local.mlflow.enable ? 1 : 0

  # run only after the gke cluster and nginx-ingress are set up
  depends_on = [
    k3d_cluster.zenml-cluster,
    module.nginx-ingress,
    module.istio,
    module.minio_server,
  ]

  # details about the mlflow deployment
  chart_version             = local.mlflow.version
  ingress_host              = "${ (local.kserve.enable || local.seldon.enable) ? "${local.mlflow.ingress_host_prefix}.${module.istio[0].ingress-ip-address}.nip.io" : "${local.mlflow.ingress_host_prefix}.${module.nginx-ingress[0].ingress-ip-address}.nip.io"}"
  tls_enabled               = false
  istio_enabled             = (local.kserve.enable || local.seldon.enable) ? true : false
  htpasswd                  = "${var.mlflow-username}:${htpasswd_password.hash.apr1}"
  artifact_Proxied_Access   = local.mlflow.artifact_Proxied_Access
  artifact_S3               = "true"
  artifact_S3_Bucket        = local.mlflow.minio_store_bucket == "" ? "${local.minio.zenml_minio_store_bucket}/mlflow" : local.mlflow.minio_store_bucket
  artifact_S3_Access_Key    = var.zenml-minio-store-access-key
  artifact_S3_Secret_Key    = var.zenml-minio-store-secret-key
  artifact_S3_Endpoint_URL  = module.minio_server[0].artifact_S3_Endpoint_URL
}

resource "htpasswd_password" "hash" {
  password = var.mlflow-password
}


# Create a bucket for MLFlow to use
resource "minio_s3_bucket" "mlflow_bucket" {
  count = (local.mlflow.enable && local.mlflow.minio_store_bucket != "") ? 1 : 0

  bucket = local.mlflow.minio_store_bucket
  force_destroy = true

  depends_on = [
    module.minio_server,
    module.nginx-ingress,
    module.istio,
  ]
}