# config values to use across the module
locals {
  prefix = "demo"
  region = "uksouth"

  resource_group = {
    name     = "zenml"
    location = "uksouth"
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
