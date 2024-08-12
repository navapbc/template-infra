output "access_policy_arn" {
  description = "The arn for the IAM access policy granting access to the user pool"
  value       = data.aws_iam_policy.existing_identity_access_policy.arn
}

output "client_id" {
  description = "The ID of the user pool client"
  value       = tolist(data.aws_cognito_user_pool_clients.existing_user_pool_clients.client_ids)[0]
}

output "client_secret_arn" {
  description = "The arn for the SSM parameter storing the user pool client secret"
  value       = data.aws_ssm_parameter.existing_user_pool_client_secret.arn
}

output "user_pool_id" {
  description = "The ID of the user pool."
  value       = tolist(data.aws_cognito_user_pools.existing_user_pools.ids)[0]
}
