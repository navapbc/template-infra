locals {
  # App name is the name of the directory that contains the app infra code
  app_name = basename(dirname(abspath(path.module)))

  environments          = ["dev", "staging", "prod"]
  image_repository_name = "${var.project_name}-${local.app_name}"
  has_database          = false
  environment_configs   = { for environment in local.environments : environment => module.env_config[environment] }
}

module "env_config" {
  for_each = toset(local.environments)

  source       = "./env-config"
  app_name     = local.app_name
  environment  = each.key
  has_database = local.has_database
}
