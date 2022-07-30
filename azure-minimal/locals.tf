# config values to use across the module
locals {
  prefix     = "demo"
  region     = "us-west1"
  
  resource_group = {
    name     = "zenml"
    location = "West Europe"
  }
  aks = {
    cluster_name = "zenml-terraform-cluster"
    # important to use 1.22 or above due to a bug with Istio in older versions
    cluster_version      = "1.23.5"
    orchestrator_version = "1.23.5"
  }
  vpc = {
    name = "zenml-vpc"
  }

  blob_storage = {
    account_name     = "zenml-account"
    container_name   = "zenml-artifact-store"
  }

  acr = {
    name = "zenml-container-registry"
  }

  seldon = {
    name      = "seldon"
    namespace = "seldon-system"
  }
  mlflow = {
    artifact_Azure = "true"
    # if not set, the container created as part of the deployment will be used
    artifact_Azure_Storage_Account_Name = ""
    # this field is considered only when the storage account above is set
    artifact_Azure_Container = ""
  }

  cloudsql = {
    name = "zenml-metadata-store"
    authorized_networks = [
      {
        name  = "all",
        value = "0.0.0.0/0"
      }
    ]
    require_ssl = true
  }

  container_registry = {
    region = "eu" # available options: eu, us, asia
  }

  artifact_repository = {
    name                      = "zenml-kubernetes"
    enable_container_registry = false
  }

  tags = {
    "managedBy"   = "terraform"
    "application" = local.prefix
  }
}