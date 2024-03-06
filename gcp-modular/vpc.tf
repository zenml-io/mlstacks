# DEPRECATION WARNING: This code has been deprecated
# The maintained & current code can be found at src/mlstacks/terraform/
# under the same relative location.

module "vpc" {
  count = (var.enable_orchestrator_kubeflow || var.enable_orchestrator_tekton || var.enable_orchestrator_kubernetes ||
    var.enable_model_deployer_kserve || var.enable_model_deployer_seldon || var.enable_experiment_tracker_mlflow ||
  var.enable_zenml) ? 1 : 0
  source  = "terraform-google-modules/network/google"
  version = "~> 4.0"

  project_id   = var.project_id
  network_name = "${local.prefix}-${local.vpc.name}-${random_string.unique.result}"

  subnets = [
    {
      subnet_name   = "${local.prefix}-${local.vpc.name}-01"
      subnet_ip     = "11.12.10.0/24"
      subnet_region = var.region
    },
    {
      subnet_name   = "${local.prefix}-${local.vpc.name}-02"
      subnet_ip     = "11.12.20.0/24"
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    "${local.prefix}-${local.vpc.name}-01" = [
      {
        range_name    = "gke-pods"
        ip_cidr_range = "10.60.0.0/14"
      },
      {
        range_name    = "gke-services"
        ip_cidr_range = "10.65.0.0/20"
      },
    ]

    # jayesh-zenml-vpc-02 = [
    #     {
    #         range_name    = "gke-pods"
    #         ip_cidr_range = "10.80.0.0/14"
    #     },
    #     {
    #         range_name    = "gke-services"
    #         ip_cidr_range = "10.85.0.0/20"
    #     },
    # ]
  }

  routes = [
    {
      name              = "${local.prefix}-igw"
      description       = "route through IGW to access internet"
      destination_range = "0.0.0.0/0"
      tags              = "egress-inet"
      next_hop_internet = "true"
    },
  ]
}
