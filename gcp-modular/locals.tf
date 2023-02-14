# config values to use across the module
locals {
  prefix = "mystack"

  # if you're using europe-west1, please make the following modification in
  # the gke.tf file:
  # For zones in google_container_cluster.gke, replace "${local.region}-a" to "${local.region}-d"
  # This is because "europe-west1-a" doesn't exist for some reason.
  region     = "us-east4"
  project_id = "zenml-ci"

  gke = {
    cluster_name = "mycluster"
    # important to use 1.22 or above due to a bug with Istio in older versions
    cluster_version      = "1.25"
    service_account_name = "account"
    workloads_namespace  = "zenml-workloads-k8s"
  }
  vpc = {
    name = "vpc"
  }

  container_registry = {
    region = "us" # available options: eu, us, asia
  }

  gcs = {
    name     = "store"
    location = "US-EAST4"
  }

  cert_manager = {
    version = "1.9.1"
  }

  istio = {
    version = "1.14.1"
  }

  nginx_ingress = {
    version = "4.4.0"
  }

  kubeflow = {
    version             = "1.8.3"
    ingress_host_prefix = "kubeflow"
  }

  tekton = {
    version             = "0.42.0"
    dashboard_version   = "0.31.0"
    ingress_host_prefix = "tekton"
    workloads_namespace = "zenml-workloads-tekton"
  }

  mlflow = {
    version                 = "0.7.13"
    artifact_Proxied_Access = "false"
    artifact_GCS            = "true"
    ingress_host_prefix = "mlflow"
  }

  kserve = {
    version              = "0.9.0"
    knative_version      = "1.8.1"
    workloads_namespace  = "zenml-workloads-kserve"
    service_account_name = "kserve"
    ingress_host_prefix  = "kserve"
  }

  seldon = {
    version              = "1.15.0"
    name                 = "seldon"
    namespace            = "seldon-system"
    workloads_namespace  = "zenml-workloads-seldon"
    service_account_name = "seldon"
  }

  zenml = {
    version                         = ""
    database_ssl_ca                 = ""
    database_ssl_cert               = ""
    database_ssl_key                = ""
    database_ssl_verify_server_cert = false
    ingress_host_prefix             = "zenml"
    ingress_tls                     = true
    image_tag                       = ""
  }

  tags = {
    "managedBy"   = "terraform"
    "application" = local.prefix
  }
}