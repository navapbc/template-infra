variable "name" {
  description = "name of the database cluster. Note that this is not the name of the Postgres database itself, but the name of the cluster in RDS. The name of the Postgres database is set in module and defaults to 'app'."
  type        = string
  validation {
    condition     = can(regex("^[-_\\da-z]+$", var.name))
    error_message = "use only lower case letters, numbers, dashes, and underscores"
  }
}
