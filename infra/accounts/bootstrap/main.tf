data "aws_region" "current" {}
data "aws_iam_account_alias" "current" {}

terraform {
  backend "local" {}
}

provider "aws" {
  region = module.project_config.default_region
}

module "project_config" {
  source = "../../project-config"
}

module "bootstrap" {
  source       = "../../modules/terraform-backend-s3"
  project_name = module.project_config.project_name
}
