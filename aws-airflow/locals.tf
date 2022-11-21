locals {
  prefix = "airflow"
  region = "eu-west-1"

  airflow = {
    environment_name = "zenml"
    # other options are: 
    # mw1.medium, mw1.large
    environment_class           = "mw1.small"
    environment_service_account = "zen"
    max_workers                 = 10
  }

  s3 = {
    name        = "dags-zenml-store"
    dags_folder = "dags"
  }

  ecr = {
    name                      = "zenml-kubernetes"
    enable_container_registry = true
  }

  network = {
    vpc_cidr = "10.192.0.0/16"
    public_subnet_cidrs = [
      "10.192.10.0/24",
      "10.192.11.0/24"
    ]
    private_subnet_cidrs = [
      "10.192.20.0/24",
      "10.192.21.0/24"
    ]
  }

  tags = {
    "managedBy"   = "terraform"
    "application" = local.prefix
  }
}