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
  value = local.tf_state_bucket_name
}

output "tf_logs_bucket_name" {
  value = local.tf_logs_bucket_name
}

output "tf_locks_table_name" {
  value = local.tf_locks_table_name
}
