# This implementation of the standard terraform VPC module
# provides a few variations of a basic VPC, based on input
# variables

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = false
  single_nat_gateway = var.single_nat_gateway

  tags = {
    Environment = var.project_name
  }
}