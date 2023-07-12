resource "random_string" "unique" {
  length  = 4
  special = false
  upper   = false
}

# config values to use across the module
locals {
  prefix = "zenml"

  eks = {
    cluster_name = "mycluster-${random_string.unique.result}"
    # important to use 1.22 or above due to a bug with Istio in older versions
    cluster_version     = "1.22"
    workloads_namespace = "zenml"
  }
  vpc = {
    name = "vpc-${random_string.unique.result}"
  }

  ecr = {
    name = var.repo_name == "" ? "container-registry-${random_string.unique.result}" : var.repo_name
  }

  s3 = {
    name = var.bucket_name == "" ? "store-${random_string.unique.result}" : var.bucket_name
  }

  cert_manager = {
    version = "1.9.1"
  }

  istio = {
    version = "1.12.0"
  }

  nginx_ingress = {
    version = "4.4.0"
  }

  kubeflow = {
    version      = "1.8.3"
    ingress_host = "kubeflow.example.com"
  }

  tekton = {
    version             = "0.40.2"
    dashboard_version   = "0.31.0"
    ingress_host        = "tekton..example.com"
    workloads_namespace = "zenml-workloads-tekton"
  }

  mlflow = {
    version                 = "0.7.13"
    artifact_Proxied_Access = "false"
    artifact_S3             = "true"

    ingress_host_prefix = "mlflow"
  }

  kserve = {
    version              = "0.9.0"
    knative_version      = "1.0.0"
    workloads_namespace  = "zenml-workloads-kserve"
    service_account_name = "kserve"
    ingress_host         = "kserve.example.com"
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
    ingress_host                    = "zenml.example.com"
    ingress_tls                     = true
    image_tag                       = ""
  }

  common_tags = {
    "managedBy"   = "terraform"
    "application" = local.prefix
  }
}
