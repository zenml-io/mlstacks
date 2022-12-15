# config values to use across the module
locals {
  k3d = {
    cluster_name = "minimal-zenml-cluster"
    image      = "rancher/k3s:v1.24.4-k3s1"
  }

  k3d_registry = {
    name = "zenml-registry"
    host = "localhost"
    port = "5001"
  }

  k3d_kube_api = {
    host = "0.0.0.0"
  }

  kubeflow = {
    pipeline_version = "1.8.3"
  }

  minio = {
    name = "zenml-minio-store"
    host = "localhost"
    port = "9000"
  }

  mlflow = {
    artifact_Proxied_Access = "false"
    artifact_S3             = "true"
    # if not set, the bucket created as part of the deployment will be used
    artifact_S3_Bucket = "zenml-mlflow-store"
  }

  seldon = {
    name      = "seldon"
    namespace = "seldon-system"
  }

  container_registry = {
    region = "eu" # available options: eu, us, asia
  }

  tags = {
    "managedBy"   = "terraform"
    "environment" = "dev"
  }
}