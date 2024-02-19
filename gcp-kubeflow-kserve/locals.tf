# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

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
    cluster_name = "terraform-kubeflow-cluster"
    # important to use 1.22 or above due to a bug with Istio in older versions
    cluster_version      = "1.22"
    service_account_name = "kubeflow"
  }
  vpc = {
    name = "kubeflow-vpc"
  }
  kubeflow = {
    pipeline_version = "1.8.3"
  }

  gcs = {
    name     = "kubeflow-artifact-store"
    location = "US-WEST1"
  }

  mlflow = {
    artifact_Proxied_Access = "false"
    artifact_GCS            = "true"
    # if not set, the bucket created as part of the deployment will be used
    artifact_GCS_Bucket = ""
  }

  kserve = {
    workloads_namespace  = "zenml-workloads"
    service_account_name = "kserve"
  }

  container_registry = {
    region = "eu" # available options: eu, us, asia
  }

  tags = {
    "managedBy"   = "terraform"
    "application" = local.prefix
  }
}
