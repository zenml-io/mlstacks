# config values to use across the module
locals {
  prefix = "demo"
  region = "eu-west-1"
  eks = {
    cluster_name = "zenml-terraform-cluster"
    # important to use 1.22 or above due to a bug with Istio in older versions
    cluster_version = "1.22"
  }
  vpc = {
    name = "zenml-vpc"
  }

  kubeflow = {
    pipeline_version = "1.8.3"
  }

  s3 = {
    name = "zenml-artifact-store"
  }

  kserve = {
    workloads_namespace  = "zenml-workloads"
    service_account_name = "kserve-sa"
  }
  mlflow = {
    artifact_S3 = "true"
    # if not set, the bucket created as part of the deployment will be used
    artifact_S3_Bucket = ""
  }

  ecr = {
    name                      = "zenml-kubernetes"
    enable_container_registry = true
  }

  rds = {
    rds_name   = "zenml-rds"
    db_name    = "zenmldb"
    db_type    = "mysql"
    db_version = "8.0.28"
  }

  tags = {
    "managedBy"   = "terraform"
    "application" = local.prefix
  }
}