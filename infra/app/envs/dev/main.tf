data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_lb" "current" {}

locals {
  environment_name = "dev"
  # The prefix key/value pair is used for Terraform Workspaces, which is useful for projects with multiple infrastructure developers.
  # By default, Terraform creates a workspace named “default.” If a non-default workspace is not created this prefix will equal “default”, 
  # if you choose not to use workspaces set this value to "dev" 
  prefix = terraform.workspace
  # Choose the region where this infrastructure should be deployed.
  region = "us-east-1"
  # Add environment specific tags
  tags = merge(module.project_config.default_tags, {
    environment = local.environment_name
    description = "Application resources created in dev environment"
  })

  tfstate_bucket = "<TF_STATE_BUCKET_NAME>"
  tfstate_key    = "infra/<APP_NAME>/environments/dev.tfstate"
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
    key            = "infra/<APP_NAME>/environments/dev.tfstate"
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
  source = "../../../project-config"
}

module "app" {
  source           = "../../env-template"
  environment_name = local.environment_name
  image_tag        = local.image_tag
}
