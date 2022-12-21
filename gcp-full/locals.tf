# config values to use across the module
locals {
  prefix = "zenml-ci"

  # if you're using europe-west1, please make the following modification in
  # the gke.tf file:
  # For zones in module.gke, replace "${local.region}-a" to "${local.region}-d"
  # This is because "europe-west1-a" doesn't exist for some reason.
  region     = "europe-west3"
  project_id = "zenml-ci"

  gke = {
    cluster_name = "cluster"
    # important to use 1.22 or above due to a bug with Istio in older versions
    cluster_version      = "1.25"
    service_account_name = "account"
    workloads_namespace  = "zenml-workloads-k8s"
  }
  vpc = {
    name = "zenml-ci-vpc"
  }

  container_registry = {
    region = "eu" # available options: eu, us, asia
  }

  gcs = {
    name     = "store"
    location = "EUROPE-WEST3"
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
    enable              = false
    version             = "1.8.3"
    ingress_host_prefix = "kubeflow.zenml-ci"
  }

  mlflow = {
    enable                  = false
    version                 = "0.7.13"
    artifact_Proxied_Access = "false"
    artifact_GCS            = "true"
    # if not set, the bucket created as part of the deployment will be used
    artifact_GCS_Bucket     = ""
    ingress_host_prefix     = "mlflow.zenml-ci"
  }

  kserve = {
    enable               = false
    version              = "0.9.0" 
    knative_version      = "1.8.1"
    workloads_namespace  = "zenml-workloads-kserve"
    service_account_name = "kserve"
    ingress_host_prefix  = "kserve.zenml-ci"
  }

  seldon = {
    enable               = false
    version              = "1.15.0"
    name                 = "seldon"
    namespace            = "seldon-system"
    workloads_namespace  = "zenml-workloads-seldon"
    service_account_name = "seldon"
  }

  zenml = {
    enable                  = false
    database_ssl_ca         = "cloudsql-server-ca-ci.pem"
    database_ssl_cert       = "cloudsql-client-cert-ci.pem"
    database_ssl_key        = "cloudsql-client-key-ci.pem"
    database_ssl_verify_server_cert = false  
    ingress_host_prefix     = "zenml.zenml-ci"
    ingress_tls             = true
    image_tag               = "ci"
  }


  tags = {
    "managedBy"   = "terraform"
    "application" = local.prefix
  }
}