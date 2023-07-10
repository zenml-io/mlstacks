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