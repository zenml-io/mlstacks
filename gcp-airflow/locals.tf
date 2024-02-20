# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# config values to use across the module
locals {
  prefix = "demo"

  # if you're using europe-west1, please make the following modification in
  # the gke.tf file:
  # For zones in module.gke, replace "${local.region}-a" to "${local.region}-d"
  # This is because "europe-west1-a" doesn't exist for some reason.
  region     = "europe-west3"
  project_id = "zenml-demos"

  airflow = {
    environment_name = "zenml"
    region           = "europe-west3"
    environment_size = "ENVIRONMENT_SIZE_SMALL"
    # other options are: 
    # ENVIRONMENT_SIZE_MEDIUM and ENVIRONMENT_SIZE_LARGE
    environment_service_account = "zen"
  }

  gcs = {
    name     = "zenml-artifact-store"
    location = "US-WEST1"
  }

  container_registry = {
    region = "eu" # available options: eu, us, asia
  }

  tags = {
    "managedBy"   = "terraform"
    "application" = local.prefix
  }
}
