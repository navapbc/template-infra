module "dev_config" {
  source                          = "./env-config"
  project_name                    = local.project_name
  app_name                        = local.app_name
  default_region                  = module.project_config.default_region
  environment                     = "dev"
  network_name                    = "dev"
  domain_name                     = "platform-test-dev.navateam.com"
  enable_https                    = true
  has_database                    = local.has_database
  has_incident_management_service = local.has_incident_management_service
}
