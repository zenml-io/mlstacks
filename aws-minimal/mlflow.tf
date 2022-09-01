# using the mlflow module to create an mlflow deployment
module "mlflow" {
  source = "./mlflow-module"

  # run only after the eks cluster is set up
  depends_on = [module.eks]

  # details about the mlflow deployment
  htpasswd                = "${var.mlflow-username}:${htpasswd_password.hash.apr1}"
  artifact_Proxied_Access = local.mlflow.artifact_Proxied_Access
  artifact_S3             = local.mlflow.artifact_S3
  artifact_S3_Bucket      = local.mlflow.artifact_S3_Bucket == "" ? aws_s3_bucket.zenml-artifact-store.bucket : local.mlflow.artifact_S3_Bucket
  artifact_S3_Access_Key  = var.mlflow-artifact-S3-access-key
  artifact_S3_Secret_Key  = var.mlflow-artifact-S3-secret-key

}

resource "htpasswd_password" "hash" {
  password = var.mlflow-password
}