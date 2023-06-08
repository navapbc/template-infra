variable "environment_name" {
  type        = string
  description = "name of the application environment"
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

variable "db_vars" {
  description = "Variables for integrating the app service with a database"
  type = object({
    security_group_id = string
    access_policy_arn = string
    connection_info = object({
      host        = string
      port        = string
      user        = string
      db_name     = string
      schema_name = string
    })
  })
  default = null
}
