# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

# config values to use across the module
locals {
  prefix = "demo"
  region = "eu-west-1"

  vpc = {
    name = "vpc"
  }

  s3 = {
    name = "artifact-store"
  }

  ecr = {
    name                      = "zenml-kubernetes"
    enable_container_registry = true
  }

  tags = {
    "managedBy"   = "terraform"
    "application" = local.prefix
  }
}
