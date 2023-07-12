# config values to use across the module
locals {
  prefix = "demo"

  # if you're using europe-west1, please make the following modification in
  # the gke.tf file:
  # For zones in module.gke, replace "${local.region}-a" to "${local.region}-d"
  # This is because "europe-west1-a" doesn't exist for some reason.
  region     = "europe-west3"
  project_id = "zenml-demos"

  gke = {
    cluster_name = "zenml-terraform-cluster"
    # important to use 1.22 or above due to a bug with Istio in older versions
    cluster_version      = "1.22"
    service_account_name = "zenml-sa"
  }
  vpc = {
    name = "zenml-vpc"
  }

  gcs = {
    name     = "zenml-artifact-store"
    location = "US-WEST1"
  }

  seldon = {
    name      = "seldon"
    namespace = "seldon-system"
  }
  mlflow = {
    artifact_Proxied_Access = "false"
    artifact_GCS            = "true"
    # if not set, the bucket created as part of the deployment will be used
    artifact_GCS_Bucket = ""
  }

  container_registry = {
    region = "eu" # available options: eu, us, asia
  }

  artifact_repository = {
    name                      = "zenml-kubernetes"
    enable_container_registry = false
  }

  common_tags = {
    "managedBy"   = "terraform"
    "application" = local.prefix
  }
}
