# This is provides a well-configured AWS VPC

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  # Choose the region where this infrastructure should be deployed.
  region = module.project_config.default_region

  # Set project tags that will be used to tag all resources. 
  tags = merge(module.project_config.default_tags, {
    description = "An AWS VPC"
  })
  # change this if you plan to have multiple vpc's
  vpc_name = "${module.project_config.project_name}-vpc"
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
  backend "s3" {
    bucket         = "<TF_STATE_BUCKET_NAME>"
    dynamodb_table = "<TF_LOCKS_TABLE_NAME>"
    key            = "infra/networks/network-aws.tfstate"
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

module "network" {
  source       = "../../modules/network-aws"
  project_name = module.project_config.project_name
  vpc_name     = local.vpc_name
  vpc_cidr     = "10.0.0.0/20"
  # 512 hosts per subnet (plus a gap in between for expansion e.g. 4 az's)
  private_subnets = ["10.0.0.0/23", "10.0.2.0/23", "10.0.4.0/23"]
  public_subnets  = ["10.0.10.0/23", "10.0.12.0/23", "10.0.14.0/23"]
  availavailability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

module "project_config" {
  source = "../../project-config"
}
