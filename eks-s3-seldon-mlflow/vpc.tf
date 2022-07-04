# VPC infra using https://github.com/terraform-aws-modules/terraform-aws-vpc
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "${local.prefix}-${local.vpc.name}"
  cidr = "10.10.0.0/16"

  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets = ["10.10.8.0/21", "10.10.16.0/21", "10.10.24.0/21"]
  public_subnets  = ["10.10.128.0/21", "10.10.136.0/21", "10.10.144.0/21"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # enabling MySQL access
  create_database_internet_gateway_route = true
  default_security_group_ingress = [
    {
      description      = "MySQL traffic from everywhere"
      from_port        = "all"
      to_port          = 3306
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    },
    {
      description      = "All Traffic"
      from_port        = "all"
      to_port          = "all"
      protocol         = "all"
    }
  ]

  tags = local.tags
}