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

  backend "s3" {
    bucket         = "platform-template-infra-368823044688-us-east-1-tf-state"
    dynamodb_table = "platform-template-infra-tf-state-locks"
    key            = "platform-template-infra/infra/account.tfstate"
    region         = "us-east-1"
    encrypt        = "true"
  }
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
