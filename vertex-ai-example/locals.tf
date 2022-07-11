# config values to use across the module
locals {
  prefix = "jayesh"
  region = "us-west1"
  project_id = "zenml-core"

  gcs = {
    name = "zenml-artifact-store"
    location = "US-WEST1"
  }

  cloudsql = {
    name = "zenml-metadata-store"
    authorized_networks = [
      {
        name = "all",
        value = "0.0.0.0/0"
      }
    ]
    require_ssl = true
  }

  artifact_repository = {
      name = "zenml-kubernetes"
      enable_container_registry = false
  }
  
  tags = {
    "managedBy"   = "terraform"
    "application" = local.prefix
  }
}