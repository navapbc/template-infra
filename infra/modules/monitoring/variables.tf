variable "service_name" {
  type        = string
  description = "List of services running within ECS cluster"
}

variable "load_balancer_arn_suffix" {
  type        = string
  description = "The ARN suffix for use with CloudWatch Metrics."
}

variable "high_http_target_5xx_error_count_threshold" {
  type        = number
  default     = null
  description = "High http service 5XX error count threshold"
}

variable "high_http_elb_5xx_error_count_threshold" {
  type        = number
  default     = null
  description = "High http ELB 5XX error count threshold"
}

variable "high_target_response_time_threshold" {
  type        = number
  default     = null
  description = "High service latency threshold"
}

