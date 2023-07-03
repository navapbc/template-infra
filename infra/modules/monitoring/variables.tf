variable "service_name" {
  type        = string
  description = "Name of the service running within ECS cluster"
}

variable "load_balancer_arn_suffix" {
  type        = string
  description = "The ARN suffix for use with CloudWatch Metrics."
}

variable "email_alerts" {
  type        = set(string)
  default     = []
  description = "List of emails for aler subscription"

}

variable "ssm_secret" {
  description = "SSM secret for external Incindent management tools"
}
