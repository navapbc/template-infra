output "client_secret_ssm_name" {
  description = "The name of the SSM parameter storing the existing user pool client secret"
  value       = "/${var.name}/identity-provider/client-secret"
}

output "user_pool_access_policy_name" {
  description = "The name of the IAM policy that grants access to the existing user pool"
  value       = "${var.name}-identity-access"
}
