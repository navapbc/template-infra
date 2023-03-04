data "aws_vpc" "vpc" {
  cidr_block = local.vpc_cidr
}

data "aws_subnets" "subnets" {
  filter {
    name   = "cidr-block"
    values = local.subnet_cidr_blocks
  }
}

locals {
  # The prefix key/value pair is used for Terraform Workspaces, which is useful for projects with multiple infrastructure developers.
  # By default, Terraform creates a workspace named “default.” If a non-default workspace is not created this prefix will equal “default”, 
  # if you choose not to use workspaces set this value to "dev" 
  prefix       = terraform.workspace == "default" ? "" : "${terraform.workspace}-"
  app_name     = module.app_config.app_name
  service_name = "${local.prefix}${local.app_name}-${var.environment_name}"
  # AWS Default VPC and subnet
  vpc_cidr           = "172.31.0.0/16"
  subnet_cidr_blocks = ["172.31.0.0/20", "172.31.16.0/20", "172.31.32.0/20"]
  # User created VPC (see infra/vpcs/vpc)
  # vpc_cidr = "10.0.0.0/20"
  # subnet_cidr_blocks = ["10.0.0.0/23", "10.0.2.0/23", "10.0.4.0/23"]
}

module "project_config" {
  source = "../../project-config"
}

module "app_config" {
  source = "../app-config"
}

module "service" {
  source                = "../../modules/service"
  service_name          = local.service_name
  image_repository_name = module.app_config.image_repository_name
  image_tag             = var.image_tag
  vpc_id                = data.aws_vpc.vpc.id
  subnet_ids            = data.aws_subnets.subnets.ids
}
