output "account_alias" {
  value = data.aws_iam_account_alias.current.account_alias
}

output "tf_state_bucket_name" {
  value = module.bootstrap.tf_state_bucket_name
}

output "tf_locks_table_name" {
  value = module.bootstrap.tf_locks_table_name
}

output "region" {
  value = data.aws_region.current.name
}
