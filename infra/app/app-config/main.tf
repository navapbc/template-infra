locals {

  # Map from environment name to the account name for the AWS account that
  # contains the resources for that environment. Resources that are shared
  # across environments use the key "shared".
  # The list of configured AWS accounts can be found in /infra/account
  # by looking for the backend config files of the form:
  #   <ACCOUNT_NAME>.<ACCOUNT_ID>.s3.tfbackend
  #
  # Projects/applications that use the same AWS account for all environments
  # will refer to the same account for all environments:
  #
  #   account_names_by_environment = {
  #     shared  = "shared"
  #     dev     = "shared"
  #     staging = "shared"
  #     prod    = "shared"
  #   }
  #
  # Projects/applications that have separate AWS accounts for each environment
  # might have a map that looks more like this:
  #
  #   account_names_by_environment = {
  #     shared  = "dev"
  #     dev     = "dev"
  #     staging = "staging"
  #     prod    = "prod"
  #   }
  account_names_by_environment = {
    shared  = "dev"
    dev     = "dev"
    staging = "staging"
    prod    = "prod"
  }
}

module "project_config" {
  source = "../../project-config"
}
