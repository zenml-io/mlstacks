module "vpc" {
  count   = local.enable_mlflow ? 1 : 0
  source  = "terraform-google-modules/network/google"
  version = "~> 4.0"

  project_id   = local.project_id
  network_name = "${local.prefix}-${local.vpc.name}"

  subnets = [
    {
      subnet_name   = "${local.prefix}-${local.vpc.name}-01"
      subnet_ip     = "10.10.10.0/24"
      subnet_region = local.region
    },
    {
      subnet_name   = "${local.prefix}-${local.vpc.name}-02"
      subnet_ip     = "10.10.20.0/24"
      subnet_region = local.region
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
      name              = "egress-internet"
      description       = "route through IGW to access internet"
      destination_range = "0.0.0.0/0"
      tags              = "egress-inet"
      next_hop_internet = "true"
    },
  ]
}