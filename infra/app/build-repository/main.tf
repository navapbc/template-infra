data "aws_iam_role" "github_actions" {
  name = module.project_config.github_actions_role_name
}

locals {
  project_name = module.project_config.project_name
  app_name     = "<APP_NAME>"
  region       = "<REGION>"

  # Set project tags that will be used to tag all resources.
  tags = merge(module.project_config.default_tags, {
    application      = local.app_name
    application_role = "build-repository"
    description      = "Backend resources required for storing built release candidate artifacts to be used for deploying to environments."
  })
}

terraform {
  required_version = ">=1.2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.20.1"
    }
  }

  # Terraform does not allow interpolation here, values must be hardcoded.

  backend "s3" {
    bucket         = "<TF_STATE_BUCKET_NAME>"
    key            = "infra/<APP_NAME>/dist.tfstate"
    dynamodb_table = "<TF_LOCKS_TABLE_NAME>"
    region         = "<REGION>"
    encrypt        = "true"
  }
}

provider "aws" {
  region = local.region
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

module "container_image_repository" {
  source               = "../../modules/container-image-repository"
  name                 = module.app_config.image_repository_name
  push_access_role_arn = data.aws_iam_role.github_actions.arn
  app_account_ids      = var.app_environment_account_ids
}
