# VPC infra using https://github.com/terraform-aws-modules/terraform-aws-vpc
module "vpc" {
  count = local.enable_eks? 1 : 0
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "${local.prefix}-${local.vpc.name}"
  cidr = "11.12.0.0/16"

  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets = ["11.12.8.0/21", "11.12.16.0/21", "11.12.24.0/21"]
  public_subnets  = ["11.12.128.0/21", "11.12.136.0/21", "11.12.144.0/21"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = local.tags
}