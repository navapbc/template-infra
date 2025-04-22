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

  # Whether or not the application should deploy a notification service.
  #
  # To use this in a particular environment, domain_name must also be set.
  # The domain name is set in infra/<APP_NAME>/app-config/<ENVIRONMENT>.tf
  # The domain name is the same domain as, or a subdomain of, the hosted zone in that environment.
  # The hosted zone is set in infra/project-config/networks.tf
  # If either (domain name or hosted zone) is not set in an environment, notifications will not actually be enabled.
  #
  # If enabled:
  # 1. Creates an AWS Pinpoint application
  # 2. Configures email notifications using AWS SES
  enable_notifications = false

  # Whether or not the application should enable WAF for the load balancer.
  # If enabled:
  # 1. Creates an AWS WAF web ACL with AWSManagedRulesCommonRuleSet
  enable_waf = false

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
