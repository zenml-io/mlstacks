# using the mlflow module to create an mlflow deployment
module "mlflow" {
  source = "./mlflow-module"

  # run only after the eks cluster is set up
  depends_on = [module.gke]
  count      = local.enable_mlflow ? 1 : 0

  # details about the mlflow deployment
  htpasswd            = "${var.mlflow-username}:${htpasswd_password.hash.apr1}"
  artifact_Proxied_Access = local.mlflow.artifact_Proxied_Access
  artifact_GCS        = local.mlflow.artifact_GCS
  artifact_GCS_Bucket = local.mlflow.artifact_GCS_Bucket == "" ? google_storage_bucket.artifact-store.name : local.mlflow.artifact_GCS_Bucket
}

resource "htpasswd_password" "hash" {
  password = var.mlflow-password
}