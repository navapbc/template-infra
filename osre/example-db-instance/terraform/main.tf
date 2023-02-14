/*
This component creates a postgresql aurora cluster for testing
*/

provider "aws" {
  region = var.aws_region
}

terraform {
  required_version = "1.0.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.54.0"
    }

    template = {
      source  = "hashicorp/template"
      version = "2.1.0"
    }
  }

  backend "s3" {}
}
