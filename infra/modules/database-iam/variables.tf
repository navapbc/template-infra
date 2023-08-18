variable "name" {
  description = "name of the database cluster. Note that this is not the name of the Postgres database itself, but the name of the cluster in RDS. The name of the Postgres database is set in module and defaults to 'app'."
  type        = string
  validation {
    condition     = can(regex("^[-_\\da-z]+$", var.name))
    error_message = "use only lower case letters, numbers, dashes, and underscores"
  }
}

variable "access_policy_name" {
  description = "name of the IAM policy to create that will be provide the ability to connect to the database as a user that will have read/write access."
  type        = string
}

variable "app_username" {
  description = "name of the database user to create that will be for the application."
  type        = string
}

variable "migrator_username" {
  description = "name of the database user to create that will be for the role that will run database migrations."
  type        = string
}
