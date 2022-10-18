data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  project_name      = "platform-template-infra"
  github_repository = "navapbc/template-infra"

  # Choose the region where this infrastructure should be deployed.
  region = "us-east-1"
}

terraform {

  required_version = "~>1.2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.20.1"
    }
  }

  # Terraform does not allow interpolation here, values must be hardcoded.

  #uncomment# backend "s3" {
  #uncomment#   bucket         = "<TF_STATE_BUCKET_NAME>"
  #uncomment#   dynamodb_table = "<TF_LOCKS_TABLE_NAME>"
  #uncomment#   key            = "<PROJECT_NAME>/infra/account.tfstate"
  #uncomment#   region         = "us-east-1"
  #uncomment#   encrypt        = "true"
  #uncomment# }
}

provider "aws" {
  region = local.region
  default_tags {
    tags = {
      project     = local.project_name
      owner       = "platform-admins"
      description = "Backend resources required for terraform state management and GitHub authentication with AWS."
      terraform   = true
    }
  }
}

module "bootstrap" {
  source       = "../../../infra/modules/terraform-backend-s3"
  project_name = local.project_name
}

module "auth_github_actions" {
  source            = "../../../infra/modules/auth-github-actions"
  project_name      = local.project_name
  github_repository = local.github_repository
}
