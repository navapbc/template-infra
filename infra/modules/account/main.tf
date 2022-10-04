data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  tf_state_bucket_name = "${var.project_name}-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-tf-state"
  tf_logs_bucket_name  = "${var.project_name}-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-tf-logs"
  tf_locks_table_name  = "${var.project_name}-tf-state-locks"
}

module "bootstrap" {
  source                 = "../../modules/bootstrap"
  state_bucket_name      = local.tf_state_bucket_name
  tf_logging_bucket_name = local.tf_logs_bucket_name
  dynamodb_table         = local.tf_locks_table_name
}

module "github_oidc" {
  source = "github.com/navapbc/terraform-aws-oidc-github"
  github_repositories = [var.github_repository]
}
