# config values to use across the module
locals {
  prefix = "k3d"

  k3d = {
    cluster_name = "minimal-zenml-cluster"
    image      = "rancher/k3s:v1.24.8-k3s1"
  }

  k3d_registry = {
    name = "minimal-registry"
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
    artifact_Proxied_Access = "true"
    artifact_GCS            = "true"
    # if not set, the bucket created as part of the deployment will be used
    artifact_GCS_Bucket = ""
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
    "application" = local.prefix
  }
}