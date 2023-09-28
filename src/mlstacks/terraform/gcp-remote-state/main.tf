provider "google" {
  project = var.project_id
  region  = var.region
}

module "gcp-remote-state" {
  source  = "zenml-io/remote-state/gcp"
  version = ">=0.1.3"

  region      = var.region
  bucket_name = var.bucket_name

  force_destroy       = var.force_destroy
  enable_versioning   = var.enable_versioning
  block_public_access = var.block_public_access
  labels              = var.labels
}

