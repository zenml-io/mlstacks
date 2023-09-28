provider "aws" {
  region = var.region
}

module "aws-remote-state" {
  source  = "zenml-io/remote-state/aws"
  version = ">=0.1.3"

  region        = var.region
  bucket_name   = var.bucket_name
  force_destroy = var.force_destroy
  tags          = var.tags
}
