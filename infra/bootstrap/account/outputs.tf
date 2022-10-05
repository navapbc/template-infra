output "project_name" {
  value = local.project_name
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "region" {
  value = data.aws_region.current.name
}

output "tf_state_bucket_name" {
  value = module.bootstrap.tf_state_bucket_name
}

output "tf_log_bucket_name" {
  value = module.bootstrap.tf_log_bucket_name
}

output "tf_locks_table_name" {
  value = module.bootstrap.tf_locks_table_name
}

output "github_actions_role_name" {
  value = module.auth_github_actions.github_actions_role_name
}

output "github_actions_role_arn" {
  value = module.auth_github_actions.github_actions_role_arn
}
