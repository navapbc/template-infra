# This implementation of the standard terraform VPC module
# provides a few variations of a basic VPC, based on input
# variables

module "network-aws" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  azs  = var.azs
  cidr = var.vpc_cidr

  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  # configurable attributes
  enable_nat_gateway = true
  single_nat_gateway = var.single_nat_gateway
  enable_vpn_gateway = var.enable_vpn_gateway
  # reasonable defaults 
  enable_dns_hostnames = true
  enable_dns_support   = true

  # See: flow_log_* params
  # https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest#input_enable_flow_log
  # I believe a good config: 
  # - log to cloudwatch logs 
  # - create an IAM role for that
  # - encrypte those logs
  enable_flow_log = false

  tags = {
    Environment = var.project_name
  }
}