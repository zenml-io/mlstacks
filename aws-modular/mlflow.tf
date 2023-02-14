# using the mlflow module to create an mlflow deployment
module "mlflow" {
  source = "../modules/mlflow-module"

  count = var.enable_mlflow ? 1 : 0

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
  artifact_S3_Bucket      = var.mlflow-s3-bucket == "" ? aws_s3_bucket.mlflow-bucket[0].bucket : var.mlflow-s3-bucket
}

resource "htpasswd_password" "hash" {
  password = var.mlflow-password
}

resource "random_string" "mlflow_bucket_suffix" {
  length  = 6
  special = false
  upper   = false
}

# create s3 bucket for mlflow
resource "aws_s3_bucket" "mlflow-bucket" {
  count         = (var.enable_mlflow && var.mlflow-s3-bucket == "") ? 1 : 0
  bucket        = "mlflow-s3-${random_string.mlflow_bucket_suffix.result}"
  force_destroy = true

  tags = local.tags
}

resource "aws_s3_bucket_acl" "mlflow" {
  count  = length(aws_s3_bucket.mlflow-bucket) > 0 ? 1 : 0
  bucket = aws_s3_bucket.mlflow-bucket[0].id
  acl    = "private"
}

# block public access to the bucket
resource "aws_s3_bucket_public_access_block" "mlflow" {
  count  = length(aws_s3_bucket.mlflow-bucket) > 0 ? 1 : 0
  bucket = aws_s3_bucket.mlflow-bucket[0].id

  block_public_acls   = true
  block_public_policy = true
}