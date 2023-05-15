locals {
  app_name              = "app"
  environments          = ["dev", "staging", "prod"]
  project_name          = module.project_config.project_name
  image_repository_name = "${local.project_name}-${local.app_name}"
}

module "project_config" {
  source = "../../project-config"
}
