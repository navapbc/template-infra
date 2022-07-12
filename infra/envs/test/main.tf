data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  # Prefix is used in the staging environement for workspaces, don't touch me here.
  prefix = "test"
  # Profile that will be used to select which account to deploy to.
  profile = "test"
  # Choose the region where this infrastructure should be deployed.
  region = "us-east-1"
  # Set project tags that will be used to tag all resources. 
  tags = {
    project     = "template-application-nextjs"
    environment = "tests"
    owner       = "platform"
    repository  = "https://github.com/navapbc/template-application-nextjs"
    description = "Application resources"
  }

}

terraform {

  required_version = ">=1.2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.20.1"
    }
  }

  # Backend arguments are required to be hardcoded. Set these values based on your account.

  # Terraform does not allow interpolation here, values must be hardcoded.
  # 
  # backend "s3" {
  #   bucket         = "AWS_ACCOUNT_ID-AWS_REGION-tf-state"
  #   key            = "terraform/tests/terraform.tfstate"
  #   region         = "REGION_OF_BUCKET"
  #   encrypt        = "true"
  #   dynamodb_table = "tf_state_locks"
  # }

}

provider "aws" {
  region  = local.region
  profile = local.profile
  default_tags {
    tags = local.tags
  }
}
