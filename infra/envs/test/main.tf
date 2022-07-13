data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  # The prefix key/value pair is used for terraform workspaces. Leave this as a static string if you are not using workspaces 
  # for this environment (recommended). If terraform.workspace is not set for <the local user?>, then it will default to the string "default" 
  # or the string "<env?>".
  prefix = terraform.workspace
  # Profile that will be used to select which account to deploy to.
  profile = "test"
  # Choose the region where this infrastructure should be deployed.
  region = "us-east-1"
  # Add environment specific tags
  tags = merge(module.common.tags, {
    environment = "test"
    description = "Application resources created in test environment"
    
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
 
  # backend "s3" {
  #   bucket         = "ACCOUNT_ID-REGION-tf-state"
  #   key            = "terraform/test/terraform.tfstate"
  #   region         = "REGION"
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

module "common" {
  source = "../../common"
}

# Add application modules below
