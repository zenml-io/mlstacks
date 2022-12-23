# using the mlflow module to create an mlflow deployment
module "mlflow" {
  source = "../modules/mlflow-module"

  count = local.mlflow.enable ? 1 : 0

  # run only after the eks cluster, cert-manager and nginx-ingress are set up
  depends_on = [
    module.eks,
    null_resource.configure-local-kubectl,
    module.cert-manager,
    module.nginx-ingress
  ]

  # details about the mlflow deployment
  chart_version           = local.mlflow.version
  htpasswd                = "${var.mlflow-username}:${htpasswd_password.hash.apr1}"
  ingress_host            = local.mlflow.ingress_host
  artifact_Proxied_Access = local.mlflow.artifact_Proxied_Access
  artifact_S3             = local.mlflow.artifact_S3
  artifact_S3_Bucket      = local.mlflow.artifact_S3_Bucket == "" ? "${aws_s3_bucket.zenml-artifact-store.bucket}/mlflow" : local.mlflow.artifact_S3_Bucket
}

resource "htpasswd_password" "hash" {
  password = var.mlflow-password
}