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

  seldon = {
    name      = "seldon"
    namespace = "seldon-system"
  }

  mlflow = {
    artifact_S3 = "true"
    # if not set, the bucket created as part of the deployment will be used
    artifact_S3_Bucket = ""
  }

  ecr = {
    name                      = "zenml-kubeflow"
    enable_container_registry = true
  }

  rds = {
    rds_name   = "rds"
    db_name    = "zenmldb"
    db_type    = "mysql"
    db_version = "8.0.28"
  }

  tags = {
    "managedBy"   = "terraform"
    "application" = local.prefix
  }
}