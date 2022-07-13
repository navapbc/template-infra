data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  # Prefix used for projects with multiple infrastructure developers, if unchanged will default to "default", or set to "staging"
  prefix = terraform.workspace
  # Profile that will be used to select which account to deploy to.
  profile = "staging"
  # Choose the region where this infrastructure should be deployed.
  region = "us-east-1"
  # Add environment specific tags
  tags = merge(module.common.tags, {
    environment = "prod"
    description = "Application resources created in staging environment"
    
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
  #   key            = "terraform/staging/terraform.tfstate"
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