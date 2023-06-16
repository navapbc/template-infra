locals {
  app_name              = "app"
  environments          = ["dev", "staging", "prod"]
  project_name          = module.project_config.project_name
  image_repository_name = "${local.project_name}-${local.app_name}"
  has_database          = false
  environment_configs   = { for environment in local.environments : environment => module.env_config[environment] }
}

module "project_config" {
  source = "../../project-config"
}

module "env_config" {
  for_each = toset(local.environments)

  source       = "./env-config"
  app_name     = local.app_name
  environment  = each.key
  has_database = local.has_database
}
