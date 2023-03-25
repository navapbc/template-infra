data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_iam_account_alias" "current" {}

locals {
  # This must match the name of the bucket created while bootstrapping the account in set-up-current-account.sh
  tf_state_bucket_name = "${module.project_config.project_name}-${data.aws_iam_account_alias.current.account_alias}-${data.aws_region.current.name}-tf"

  # Choose the region where this infrastructure should be deployed.
  region = module.project_config.default_region

  # Set project tags that will be used to tag all resources. 
  tags = merge(module.project_config.default_tags, {
    description = "Backend resources required for terraform state management and GitHub authentication with AWS."
  })
}

terraform {

  required_version = "~>1.2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.20.1"
    }
  }

  backend "s3" {
    key     = "infra/account.tfstate"
    encrypt = "true"
  }
}

provider "aws" {
  region = local.region
  default_tags {
    tags = local.tags
  }
}

module "project_config" {
  source = "../project-config"
}

module "backend" {
  source = "../modules/terraform-backend-s3"
  name   = local.tf_state_bucket_name
}

module "auth_github_actions" {
  source                   = "../modules/auth-github-actions"
  github_actions_role_name = module.project_config.github_actions_role_name
  github_repository        = module.project_config.code_repository
}
