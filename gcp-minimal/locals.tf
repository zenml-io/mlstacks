# config values to use across the module
locals {
  prefix     = "demo"
  region     = "europe-west3"
  project_id = "zenml-demos"
  gke = {
    cluster_name = "zenml-terraform-cluster"
    # important to use 1.22 or above due to a bug with Istio in older versions
    cluster_version      = "1.22"
    service_account_name = "zenml"
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
    artifact_GCS = "true"
    # if not set, the bucket created as part of the deployment will be used
    artifact_GCS_Bucket = ""
  }

  cloudsql = {
    name = "zenml-metadata-store-demo"
    authorized_networks = [
      {
        name  = "all",
        value = "0.0.0.0/0"
      }
    ]
    require_ssl = true
  }

  container_registry = {
    region = "eu" # available options: eu, us, asia
  }

  artifact_repository = {
    name                      = "zenml-kubernetes"
    enable_container_registry = false
  }

  tags = {
    "managedBy"   = "terraform"
    "application" = local.prefix
  }
}