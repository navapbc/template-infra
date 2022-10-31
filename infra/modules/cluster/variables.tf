variable "environment_name" {
  description = "name of the environment"
  validation {
    condition     = can(regex("^[-_\\da-z]+$", var.environment_name))
    error_message = "use only lower case letters, numbers, dashes, and underscores"
  }
}
