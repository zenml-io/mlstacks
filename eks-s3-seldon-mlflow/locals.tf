# config values to use across the module
locals {
  prefix = "jayesh"
  region = "us-east-1"
  eks = {
    cluster_name = "zenml-terraform-cluster"
    # important to use 1.22 or above due to a bug with Istio in older versions
    cluster_version = "1.22"
  }
  vpc = {
    name = "zenml-vpc"
  }

  s3 = {
    name = "zenml-artifact-store"
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

    rds = {
    rds_name = "zenml-rds"
    db_name = "zenml-db"
    db_type = "mysql"
    db_version = "8.0.28"
    username = "admin"
    password = "k8szenml"
  }
  
  tags = {
    "managedBy"   = "terraform"
    "application" = local.prefix
  }
}