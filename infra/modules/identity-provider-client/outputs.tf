output "access_policy_arn" {
  value = aws_iam_policy.cognito_access.arn
}

output "client_id" {
  description = "The ID of the user pool client"
  value       = aws_cognito_user_pool_client.client.id
}

output "client_secret_arn" {
  description = "The arn for the SSM parameter storing the user pool client secret"
  value       = aws_ssm_parameter.client_secret.arn
}
