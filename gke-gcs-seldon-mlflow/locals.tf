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
    htpasswd = "user:$apr1$9gkx2wij$JynUCfSc211GYkmb4MmBF1"
    artifact_S3 = "true"
    # if not set, the bucket created as part of the deployment will be used
    artifact_S3_Bucket = ""
    artifact_S3_Access_Key = "AKIAJX7X7X7X7X7X7X7X"
    artifact_S3_Secret_Key = "JbtUCfSc211GYkmZ5MmBF1"
  }

  ecr = {
      name = "zenml-kubernetes"
      enable_container_registry = true
  }
  
  tags = {
    "managedBy"   = "terraform"
    "application" = local.prefix
  }
}