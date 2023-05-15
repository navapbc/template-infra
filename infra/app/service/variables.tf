variable "environment_name" {
  type        = string
  description = "name of the application environment"
}

variable "load_balancer_security_group_id" {
  type        = string
  description = "The ID of the security group to associate with the load balancer."
}

variable "service_security_group_id" {
  type        = string
  description = "The ID of the security group to associate with the application service."
}

variable "image_tag" {
  type        = string
  description = "image tag to deploy to the environment"
  default     = null
}

variable "tfstate_bucket" {
  type = string
}

variable "tfstate_key" {
  type = string
}

variable "region" {
  type = string
}
