variable "client_secret_ssm_name" {
  type        = string
  description = "The name of the SSM parameter storing the existing user pool client secret"
}

variable "name" {
  type        = string
  description = "The name of an existing cognito user pool"
}

variable "user_pool_access_policy_name" {
  type        = string
  description = "The name of the IAM policy that grants access to the existing user pool"
}
