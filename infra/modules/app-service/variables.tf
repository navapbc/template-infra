variable "app_name" {
  description = "name of the app, to be used for infra structure resource naming"
  validation {
    condition     = can(regex("^[-_\\da-z]+$", var.app_name))
    error_message = "use only lower case letters, numbers, dashes, and underscores"
  }
}

variable "environment_name" {
  description = "name of the environment, to be used for infra structure resource naming"
  validation {
    condition     = can(regex("^[-_\\da-z]+$", var.environment_name))
    error_message = "use only lower case letters, numbers, dashes, and underscores"
  }
}

variable "ecs_cluster_arn" {
  type        = string
  description = "ARN of the ECS cluster to use for the app service"
  validation {
    condition     = can(regex("^arn:aws:ecs:[-\\da-z]+:\\d+:cluster/[-_\\d\\w]+$"), var.ecs_cluster_arn)
    error_message = "provide a valid ARN for an ECS cluster"
  }
}

variable "desired_instance_count" {
  type        = number
  description = "Number of instances of the task definition to place and keep running."
  default     = 1
}

variable "cpu" {
  type    = number
  default = 2048
}

variable "ram_size" {
  type    = number
  default = 2048
}

variable "container_definitions" {
  type = string
}
