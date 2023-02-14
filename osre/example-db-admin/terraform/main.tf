provider "aws" {
  region = var.aws_region
}

terraform {
  required_version = "1.0.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.5.0"
    }

    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.16.0"
    }
  }

  backend "s3" {}
}
