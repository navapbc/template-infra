data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  # The prefix key/value pair is used for Terraform Workspaces, which is useful for projects with multiple infrastructure developers.
  # By default, Terraform creates a workspace named “default.” If a non-default workspace is not created this prefix will equal “default”, 
  # if you choose not to use workspaces set this value to "dev" 
  prefix = terraform.workspace
  # Choose the region where this infrastructure should be deployed.
  region = "us-east-1"
  # Add environment specific tags
  tags = merge(module.common.default_tags, {
    environment = "dev"
    description = "Application resources created in dev environment"
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
    key            = "<PROJECT_NAME>/infra/<APP_NAME>/environments/dev.tfstate"
    dynamodb_table = "<TF_LOCKS_TABLE_NAME>"
    region         = "<REGION>"
    encrypt        = "true"
  }
}

provider "aws" {
  region  = local.region
  default_tags {
    tags = local.tags
  }
}

module "common" {
  source = "../../modules/common"
}

# Add application modules below

module "example" {
  source = "../../modules/example"
  prefix = local.prefix
}