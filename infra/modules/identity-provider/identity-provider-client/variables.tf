variable "callback_urls" {
  type        = list(string)
  description = "The URL(s) that the identity provider will redirect to after a successful login"
  default     = []
}

variable "client_secret_ssm_name" {
  type        = string
  description = "The name of the SSM parameter to store the user pool client secret in"
}

variable "cognito_user_pool_id" {
  type        = string
  description = "The ID of the user pool that the client will be associated with"
}

variable "logout_urls" {
  type        = list(string)
  description = "The URL that the identity provider will redirect to after a successful logout"
  default     = []
}

variable "name" {
  type        = string
  description = "Name of the application or service that will act as a client to the identity provider"
}

variable "user_pool_access_policy_name" {
  type        = string
  description = "The name of the IAM policy that will grant access to the user pool"
}
