# config values to use across the module
locals {
  prefix = "kflow"
  region = "eu-west-1"
  eks = {
    cluster_name = "zenml-cluster"
    # important to use 1.22 or above due to a bug with Istio in older versions
    cluster_version = "1.22"
  }
  vpc = {
    name = "vpc"
  }

  kubeflow = {
    pipeline_version = "1.8.3"
  }

  s3 = {
    name = "artifact-store"
  }

  kserve = {
    workloads_namespace  = "zenml-workloads"
    service_account_name = "kserve-sa"
  }
  mlflow = {
    artifact_Proxied_Access = "false"
    artifact_S3             = "true"
    # if not set, the bucket created as part of the deployment will be used
    artifact_S3_Bucket = ""
  }

  ecr = {
    name                      = "zenml-kubeflow"
    enable_container_registry = true
  }

  common_tags = {
    "managedBy"   = "terraform"
    "application" = local.prefix
  }
}
