# using the mlflow module to create an mlflow deployment
module "mlflow" {
  source = "../modules/mlflow-module"

  count = local.mlflow.enable ? 1 : 0

  # run only after the gke cluster, cert-manager and nginx-ingress are set up
  depends_on = [
    k3d_cluster.zenml-cluster,
    module.cert-manager,
    module.nginx-ingress
  ]

  # details about the mlflow deployment
  chart_version           = local.mlflow.version
  ingress_host            = "mlflow.localhost"
  htpasswd                = "${var.mlflow-username}:${htpasswd_password.hash.apr1}"
  artifact_Proxied_Access = local.mlflow.artifact_Proxied_Access
  artifact_S3             = local.mlflow.artifact_S3
  artifact_S3_Bucket      = local.minio.mlflow_minio_store_bucket
  artifact_S3_Access_Key  = var.zenml-minio-store-access-key
  artifact_S3_Secret_Key  = var.zenml-minio-store-secret-key

  # set workload identity annotations for mlflow kubernetes sa
  # kubernetes_sa = google_service_account.gke-service-account.email
}

resource "htpasswd_password" "hash" {
  password = var.mlflow-password
}