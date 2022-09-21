# config values to use across the module
locals {
  prefix = "demo"
  region = "us-west1"

  resource_group = {
    name     = "zenml"
    location = "West Europe"
  }

  azureml = {
    cluster_name = "zenml-terraform-cluster"
  }
  vpc = {
    name = "zenmlvpc"
  }

  blob_storage = {
    account_name   = "zenmlaccount"
    container_name = "zenmlartifactstore"
  }


  mysql = {
    name = "zenmlmetadata"
  }

  key_vault = {
    name = "zenmlsecrets"
  }

  tags = {
    "managedBy"   = "terraform"
    "application" = local.prefix
  }
}
