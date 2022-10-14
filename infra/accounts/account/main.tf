data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  project_name      = "<PROJECT_NAME>"
  github_repository = "<GITHUB_REPOSITORY>"

  # Choose the region where this infrastructure should be deployed.
  region = "us-east-1"

  # Set project tags that will be used to tag all resources. 
  tags = merge(module.common.default_tags, {
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

  # Terraform does not allow interpolation here, values must be hardcoded.

  #uncomment# backend "s3" {
  #uncomment#   bucket         = "<TF_STATE_BUCKET_NAME>"
  #uncomment#   dynamodb_table = "<TF_LOCKS_TABLE_NAME>"
  #uncomment#   key            = "terraform/backend/terraform.tfstate"
  #uncomment#   region         = "us-east-1"
  #uncomment#   encrypt        = "true"
  #uncomment# }

}

provider "aws" {
  region = local.region
  default_tags {
    tags = local.tags
  }
}

module "common" {
  source = "../../modules/common"
}

module "bootstrap" {
  source       = "../../modules/terraform-backend"
  project_name = local.project_name
}

module "auth_github_actions" {
  source            = "../../modules/auth-github-actions"
  project_name      = local.project_name
  github_repository = local.github_repository
}
