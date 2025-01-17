locals {
  # The prefix key/value pair is used for Terraform Workspaces, which is useful for projects with multiple infrastructure developers.
  # By default, Terraform creates a workspace named “default.” If a non-default workspace is not created this prefix will equal “default”,
  # if you choose not to use workspaces set this value to "dev"
  prefix = terraform.workspace == "default" ? "" : "${terraform.workspace}-"

  # Add environment specific tags
  tags = merge(module.project_config.default_tags, {
    environment = var.environment_name
    description = "Database resources for the ${var.environment_name} environment"
  })

  is_temporary = terraform.workspace != "default"

  environment_config = module.app_config.environment_configs[var.environment_name]
  database_config    = local.environment_config.database_config
}

terraform {
  required_version = "~>1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.67.0"
    }
  }

  backend "s3" {
    encrypt = "true"
  }
}

provider "aws" {
  region = local.database_config.region
  default_tags {
    tags = local.tags
  }
}

module "project_config" {
  source = "../../project-config"
}

module "app_config" {
  source = "../app-config"
}

module "database" {
  source = "../../modules/database"

  name                        = "${local.prefix}${local.database_config.cluster_name}"
  app_access_policy_name      = "${local.prefix}${local.database_config.app_access_policy_name}"
  migrator_access_policy_name = "${local.prefix}${local.database_config.migrator_access_policy_name}"

  # The following are not AWS infra resources and therefore do not need to be
  # isolated via the terraform workspace prefix
  app_username      = local.database_config.app_username
  migrator_username = local.database_config.migrator_username
  schema_name       = local.database_config.schema_name

  vpc_id                         = module.network.vpc_id
  database_subnet_group_name     = module.network.database_subnet_group_name
  private_subnet_ids             = module.network.database_subnet_ids
  aws_services_security_group_id = module.network.aws_services_security_group_id
  is_temporary                   = local.is_temporary
}
