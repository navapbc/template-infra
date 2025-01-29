locals {
  # app_name is the name of the application, which by convention should match the name of
  # the folder under /infra that corresponds to the application
  app_name = regex("/infra/([^/]+)/app-config$", abspath(path.module))[0]

  environments = ["dev", "staging", "prod"]
  project_name = module.project_config.project_name

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

  has_incident_management_service = false

  # Whether or not the application should deploy an identity provider
  # If enabled:
  # 1. Creates a Cognito user pool
  # 2. Creates a Cognito user pool app client
  # 3. Adds environment variables for the app client to the service
  enable_identity_provider = false

  # Whether or not the application should deploy a notification service
  # Note: This is not yet ready for use.
  # TODO(https://github.com/navapbc/template-infra/issues/567)
  enable_notifications = false

  environment_configs = {
    dev     = module.dev_config
    staging = module.staging_config
    prod    = module.prod_config
  }

  # The name of the network that contains the resources shared across all
  # application environments, such as the build repository.
  # The list of networks can be found in /infra/networks
  # by looking for the backend config files of the form:
  #   <NETWORK_NAME>.s3.tfbackend
  shared_network_name = "dev"
}

module "project_config" {
  source = "../../project-config"
}
