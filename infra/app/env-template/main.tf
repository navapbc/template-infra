locals {
  # The prefix key/value pair is used for Terraform Workspaces, which is useful for projects with multiple infrastructure developers.
  # By default, Terraform creates a workspace named “default.” If a non-default workspace is not created this prefix will equal “default”, 
  # if you choose not to use workspaces set this value to "dev" 
  prefix       = terraform.workspace == "default" ? "" : "${terraform.workspace}-"
  app_name     = module.app_config.app_name
  service_name = "${local.prefix}${local.app_name}-${var.environment_name}"
}

module "aws_vpc" {
  source       = "../../modules/vpc"
  project_name = module.project_config.project_name
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
  vpc_id                = module.aws_vpc.vpc_id
  subnet_ids            = module.aws_vpc.private_subnets
  subnet_ids_public     = module.aws_vpc.public_subnets
}
