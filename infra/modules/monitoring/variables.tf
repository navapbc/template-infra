variable "service_name" {
  type        = string
  description = "Name of the service running within ECS cluster"
}

variable "load_balancer_arn_suffix" {
  type        = string
  description = "The ARN suffix for use with CloudWatch Metrics."
}
