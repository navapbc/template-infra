# TODO(https://github.com/navapbc/template-infra/issues/152) use non-default VPC
data "aws_vpc" "default" {
  default = true
}

# TODO(https://github.com/navapbc/template-infra/issues/152) use private subnets
data "aws_subnets" "default" {
  filter {
    name   = "default-for-az"
    values = [true]
  }
}

locals {
  project_name = module.project_config.project_name
  app_name     = module.app_config.app_name
  service_name = "${local.project_name}-${local.app_name}-${var.environment_name}"
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
  vpc_id                = data.aws_vpc.default.id
  subnet_ids            = data.aws_subnets.default.ids
}
