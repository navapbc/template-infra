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
  source       = "../../modules/app-service"
  service_name = local.service_name
}
