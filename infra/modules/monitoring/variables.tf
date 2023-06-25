variable "ecs_name" {
  type        = string
  description = "Target ECS cluster name"
}

variable "cpu_threshold" {
  type        = string
  description = "CPU threshold for cloudwatch CPU alarm"
}

variable "memory_util_threshold" {
  type        = string
  description = "Memory utilization threshold for cloudwatch alarm"
}

variable "task_health_threshold" {
  type        = string
  description = "Task health threshoold for cloudwatch alarm"
}

variable "network_connectivity_threshold" {
  type        = string
  description = "Network connectivity threshold for cloudwatch alarm"
}

variable "service_availability_threshold" {
  type        = string
  description = "Service availability threshold for cloudwatch alarm"
}

variable "task_placement_threshold" {
  type        = string
  description = "Task placement threshold for cloudwatch alarm"
}
