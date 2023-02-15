locals {
  name = "${var.environment_name}-${var.aws_region}-${var.application_name}"
}

data "aws_caller_identity" "current" {} 