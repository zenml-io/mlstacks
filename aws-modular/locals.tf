# config values to use across the module
locals {
  prefix = "mystack"
  region = "us-east-1"
  eks = {
    cluster_name = "mycluster"
    # important to use 1.22 or above due to a bug with Istio in older versions
    cluster_version = "1.22"
    workloads_namespace = "zenml-workloads-k8s"
  }
  vpc = {
    name = "vpc"
  }

  ecr = {
    name = "container-registry"
  }

  s3 = {
    name = "store"
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
    enable              = true
    version             = "1.8.3"
    ingress_host = "kubeflow.example.com"
  }

  tekton = {
    enable              = true
    version             = "0.40.2"
    dashboard_version   = "0.31.0"
    ingress_host        = "tekton..example.com"
    workloads_namespace  = "zenml-workloads-tekton"
  }

  mlflow = {
    enable                  = true
    version                 = "0.7.13"
    artifact_Proxied_Access = "false"
    artifact_S3             = "true"
    # if not set, the bucket created as part of the deployment will be used
    artifact_S3_Bucket      = ""
    ingress_host            = "mlflow.example.com"
  }

  kserve = {
    enable               = true
    version              = "0.9.0" 
    knative_version      = "1.0.0"
    workloads_namespace  = "zenml-workloads-kserve"
    service_account_name = "kserve"
    ingress_host         = "kserve.example.com"
  }

  seldon = {
    enable               = true
    version              = "1.15.0"
    name                 = "seldon"
    namespace            = "seldon-system"
    workloads_namespace  = "zenml-workloads-seldon"
    service_account_name = "seldon"
  }

  zenml = {
    enable                  = true
    database_ssl_ca         = ""
    database_ssl_cert       = ""
    database_ssl_key        = ""
    database_ssl_verify_server_cert = false  
    ingress_host            = "zenml.example.com"
    ingress_tls             = true
    image_tag               = ""
  }

  tags = {
    "managedBy"   = "terraform"
    "application" = local.prefix
  }
}