provider "aws" {
  region = var.region
}

module "aws-remote-state" {
  source  = "zenml-io/terraform-aws-remote-state"
  version = ">=0.1.3"

  region        = var.region
  bucket_name   = var.bucket_name
  force_destroy = var.force_destroy
  tags          = var.tags
}
