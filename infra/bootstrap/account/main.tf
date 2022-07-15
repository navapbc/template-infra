data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  # Profile that will be used to select which account to deploy to. This profile name should be propagated to the
  # environment(s) that will share this aws account.
  profile = "default"
  # Choose the region where this infrastructure should be deployed.
  region = "us-east-1"
  # Set project tags that will be used to tag all resources. 
  tags = merge(module.common.default_tags, {
    description = "Backend resources required for terraform state management."

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
 
  # backend "s3" {
  #   bucket         = "ACCOUNT_ID-REGION-tf-state"
  #   key            = "terraform/backend/terraform.tfstate"
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

module "bootstrap" {
  source                 = "../../modules/bootstrap"
  state_bucket_name      = "${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-tf-state"
  tf_logging_bucket_name = "${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-tf-logs"
  dynamodb_table         = "tf_state_locks"
}
