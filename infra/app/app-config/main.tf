locals {
  # app_name is the name of the application, which by convention should match the name of
  # the folder under /infra that corresponds to the application
  app_name = regex("/infra/([^/]+)/app-config$", abspath(path.module))[0]

  environments          = ["dev", "staging", "prod"]
  project_name          = module.project_config.project_name
  image_repository_name = "${local.project_name}-${local.app_name}"

  # Whether or not the application has a database
  # If enabled:
  # 1. The networks associated with this application's environments will have
  #    VPC endpoints needed by the database layer
  # 2. Each environment's config will have a database_config property that is used to
  #    pass db_vars into the infra/modules/service module, which provides the necessary
  #    configuration for the service to access the database
  has_database = true

  # Whether or not the application depends on external non-AWS services.
  # If enabled, the networks associated with this application's environments
  # will have NAT gateways, which allows the service in the private subnet to
  # make calls to the internet.
  has_external_non_aws_service = false

  has_incident_management_service = true

  environment_configs = {
    dev     = module.dev_config
    staging = module.staging_config
    prod    = module.prod_config
  }

  build_repository_config = {
    region = module.project_config.default_region
  }

  # The name of the AWS account that contains the resources shared across all
  # application environments, such as the build repository.
  # The list of configured AWS accounts can be found in /infra/account
  # by looking for the backend config files of the form:
  #   <ACCOUNT_NAME>.<ACCOUNT_ID>.s3.tfbackend
  shared_account_name = "dev"
}

module "project_config" {
  source = "../../project-config"
}
