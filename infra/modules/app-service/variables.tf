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
    condition     = can(regex("^arn:aws:ecs:[-\\da-z]+:\\d+:cluster/[-_\\d\\w]+$", var.ecs_cluster_arn))
    error_message = "provide a valid ARN for an ECS cluster"
  }
}

variable "desired_instance_count" {
  type        = number
  description = "Number of instances of the task definition to place and keep running."
  default     = 1
}

variable "cpu" {
  type        = number
  default     = 2048
  description = "Number of cpu units used by the task, expessed as an integer value, e.g 512 "
}

variable "memory" {
  type        = number
  default     = 2048
  description = "Amount (in MiB) of memory used by the task. e.g. 2048"
}

variable "container_definitions" {
  type = string
}

variable "prefix" {
  type        = string
  description = "Special identifer that will allow resources to deploy without interfering with other common resources."
}

variable "ecs_cluster_name" {
  type        = string
  description = "A user-generated string that used to identify the cluster."
}

variable "ecs_service_name" {
  type        = string
  description = "A user-generated string that used to identify the service."
}

variable "vpc_id" {
  type        = string
  description = "Uniquely identifies the VPC."
}

variable "subnet_ids" {
  type        = list(any)
  description = "Private subnet id from vpc module"
}

variable "aws_region" {
  type        = string
  description = "Region where resources will be deployed"
}

variable "desired_count" {
  type        = string
  description = "number of tasks to spin up"
}

variable "ecs_target_group_arn" {
  type        = string
  description = "Amazon resource name of the target group."

}

variable "ecr_repo_name" {
  type        = string
  description = "A user-generated string that used to identify the elastic container registry repository."
}

variable "image_url" {
  type        = string
  description = "The URL for the image to deploy"
}

variable "container_port" {
  type        = number
  description = "The port number on the container that's bound to the user-specified"
}
