# config values to use across the module
locals {
  k3d = {
    cluster_name        = "minimal-zenml-cluster"
    image               = "rancher/k3s:v1.24.4-k3s1"
    local_stores_path   = ""
    workloads_namespace = "zenml-workloads-k8s"
  }

  k3d_registry = {
    name = "zenml-registry"
    host = "localhost"
    port = "5001"
  }

  k3d_kube_api = {
    host = "0.0.0.0"
  }

  minio = {
    storage_size = "10Gi"
    zenml_minio_store_bucket = "zenml-minio-store"
    ingress_host_prefix = "minio"
    ingress_console_host_prefix = "minio-console"
  }

  istio = {
    version = "1.14.1"
  }

  nginx_ingress = {
    version = "4.4.0"
  }

  kubeflow = {
    enable              = true
    version             = "1.8.3"
    ingress_host_prefix = "kubeflow"
  }

  tekton = {
    enable              = false
    version             = "0.42.0"
    dashboard_version   = "0.31.0"
    ingress_host_prefix = "tekton"
    workloads_namespace  = "zenml-workloads-tekton"
  }

  mlflow = {
    enable                  = true
    version                 = "0.7.13"
    artifact_Proxied_Access = "false"
    ingress_host_prefix     = "mlflow"
    minio_store_bucket      = "mlflow-minio-store"
  }

  kserve = {
    enable               = false
    version              = "0.9.0" 
    knative_version      = "1.8.1"
    workloads_namespace  = "zenml-workloads-kserve"
    service_account_name = "kserve"
    ingress_host_prefix  = "kserve"
  }

  seldon = {
    enable               = false
    version              = "1.15.0"
    name                 = "seldon"
    namespace            = "seldon-system"
    workloads_namespace  = "zenml-workloads-seldon"
    service_account_name = "seldon"
  }

  tags = {
    "managedBy"   = "terraform"
    "environment" = "dev"
  }
}