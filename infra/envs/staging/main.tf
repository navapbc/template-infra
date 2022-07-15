data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  # The prefix key/value pair is used for terraform workspaces, which is useful for projects with multiple infrastructure developers. 
  # Leave this as a static string if you are not using workspaces for this environment (recommended). Change it to terraform.workspace 
  # if you want to use workspaces in this environment.
  prefix = "staging"
  # Profile is used to select which aws credentials to use, set this to match the account this environement runs in.
  profile = "default"
  # Choose the region where this infrastructure should be deployed.
  region = "us-east-1"
  # Add environment specific tags
  tags = merge(module.common.default_tags, {
    environment = "staging"
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
  source = "../../modules/common"
}

# Add application modules below