data "aws_availability_zones" "available" {}

locals {
  vpc_cidr               = "10.0.0.0/20"
  num_availability_zones = 3
  availability_zones     = slice(data.aws_availability_zones.available.names, 0, local.num_availability_zones)
}

module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.2.0"

  name = var.name
  azs  = local.availability_zones
  cidr = local.vpc_cidr

  # Public subnets
  public_subnets     = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
  public_subnet_tags = { subnet_type = "public" }

  # Private subnets
  private_subnets     = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_tags = { subnet_type = "private" }

  # Database subnets
  # `database_subnet_tags` is only used if `database_subnets` is not empty
  # `database_subnet_group_name` is only used if `create_database_subnet_group` is true
  database_subnets             = var.has_database ? ["10.0.5.0/24", "10.0.6.0/24", "10.0.7.0/24"] : []
  database_subnet_tags         = { subnet_type = "database" }
  create_database_subnet_group = var.has_database
  database_subnet_group_name   = var.database_subnet_group_name

  # If application needs external services, then create one NAT gateway per availability zone
  enable_nat_gateway     = var.has_external_non_aws_service
  single_nat_gateway     = false
  one_nat_gateway_per_az = var.has_external_non_aws_service

  enable_dns_hostnames = true
  enable_dns_support   = true
}
