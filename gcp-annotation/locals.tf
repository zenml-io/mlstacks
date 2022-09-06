# config values to use across the module
locals {
  prefix = "demo"

  # if you're using europe-west1, please make the following modification in
  # the gke.tf file:
  # For zones in module.gke, replace "${local.region}-a" to "${local.region}-d"
  # This is because "europe-west1-a" doesn't exist for some reason.
  region     = "europe-west3"
  project_id = "zenml-demos"

  gcs = {
    name     = "annotation-store"
    location = "US-WEST1"
  }

  container_registry = {
    region = "eu" # available options: eu, us, asia
  }

  tags = {
    "managedBy"   = "terraform"
    "application" = local.prefix
  }
}