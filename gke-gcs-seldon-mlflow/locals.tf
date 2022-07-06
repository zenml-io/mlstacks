# config values to use across the module
locals {
  prefix = "jayesh"
  region = "us-west1"
  project_id = "zenml-core"
  gke = {
    cluster_name = "zenml-terraform-cluster"
    # important to use 1.22 or above due to a bug with Istio in older versions
    cluster_version = "1.22"
    service_account_name = "zenml"
  }
  vpc = {
    name = "zenml-vpc"
  }

  gcs = {
    name = "zenml-artifact-store"
    location = "US-WEST1"
  }

  seldon = {
      name = "seldon"
      namespace = "seldon-system"
  }
  mlflow = {
    artifact_GCS = "true"
    # if not set, the bucket created as part of the deployment will be used
    artifact_GCS_Bucket = ""
  }

  cloudsql = {
    name = "zenml-metadata-store"
    authorized_networks = ["0.0.0.0/0"]
    require_ssl = true
  }

  artifact_repository = {
      name = "zenml-kubernetes"
      enable_container_registry = true
  }
  
  tags = {
    "managedBy"   = "terraform"
    "application" = local.prefix
  }
}