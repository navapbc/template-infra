locals {
  project_name = var.project_name
  vpc_name     = "vpc-${local.project_name}"
  region       = module.project_config.default_region
  cidr_prefix  = "172.30." # Value should be between "172.16." & "172.31."
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.18.1"

  # Basic Details
  name = local.vpc_name
  cidr = "${local.cidr_prefix}0.0/16"

  # Subnets availablity zones
  azs = ["${local.region}a", "${local.region}b", "${local.region}c", "${local.region}d", "${local.region}e", "${local.region}f"]

  # Subnet - Private 
  private_subnets      = ["${local.cidr_prefix}0.0/20", "${local.cidr_prefix}16.0/20", "${local.cidr_prefix}32.0/20"]
  enable_nat_gateway   = true
  single_nat_gateway   = true # Disable if you want a nat gateway for each AZ. This will become expensive
  private_subnet_names = ["Private Subnet One", "Private Subnet Two", "Private Subnet Three"]
  private_subnet_tags = {
    Name = "${local.project_name}-private-subnets"
  }

  # Subnet - Public 
  public_subnets      = ["${local.cidr_prefix}48.0/20", "${local.cidr_prefix}64.0/20", "${local.cidr_prefix}80.0/20"]
  public_subnet_names = ["Public Subnet One", "Public Subnet Two", "Public Subnet Three"]
  public_subnet_tags = {
    Name = "${local.project_name}-public-subnets"
  }
  #   # Database
  #   create_database_subnet_group       = true
  #   create_database_subnet_route_table = true
  #   database_subnets                   = ["${local.cidr_prefix}96.0/20", "${local.cidr_prefix}112.0/20", "${local.cidr_prefix}128.0/20"]
  #   database_subnet_names    = ["DB Subnet One", "DB Subnet Two", "DB Subnet Three"]
  #   database_subnet_tags = {
  #     Name = "${local.project_name}-DB-subnets"
  #   }
  # VPC DNS
  enable_dns_support   = true
  enable_dns_hostnames = true
}
