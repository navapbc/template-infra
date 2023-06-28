variable "cluster_name" {
  type        = string
  description = "Target ECS cluster name"
}

variable "high_cpu_usage_alert_threshold" {
  type        = number
  default     = null
  description = "CPU threshold for cloudwatch CPU alarm"
}

variable "high_memory_util_threshold" {
  type        = number
  default     = null
  description = "Memory utilization threshold for cloudwatch alarm"
}

variable "task_health_percentage_threshold" {
  type        = number
  default     = null
  description = "Task health threshoold for cloudwatch alarm"
}

variable "high_network_packet_loss_threshold" {
  type        = number
  default     = null
  description = "Network connectivity threshold for cloudwatch alarm"
}

variable "service_availability_threshold" {
  type        = number
  default     = null
  description = "Service availability threshold for cloudwatch alarm"
}

variable "task_placement_error_threshold" {
  type        = number
  default     = null
  description = "Task placement threshold for cloudwatch alarm"
}
