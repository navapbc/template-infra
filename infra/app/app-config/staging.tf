module "staging_config" {
  source                          = "./env-config"
  project_name                    = local.project_name
  app_name                        = local.app_name
  default_region                  = module.project_config.default_region
  environment                     = "staging"
  network_name                    = "staging"
  domain_name                     = null
  enable_https                    = false
  has_database                    = local.has_database
  has_incident_management_service = local.has_incident_management_service

  # Enables ECS Exec access for debugging or jump access.
  # Set to `true` to enable. Defaults to `false`.
  # See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-exec.html
  enable_service_execution = false
}
