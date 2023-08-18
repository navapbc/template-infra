variable "name" {
  description = "name of the database cluster. Note that this is not the name of the Postgres database itself, but the name of the cluster in RDS. The name of the Postgres database is set in module and defaults to 'app'."
  type        = string
  validation {
    condition     = can(regex("^[-_\\da-z]+$", var.name))
    error_message = "use only lower case letters, numbers, dashes, and underscores"
  }
}

variable "vpc_id" {
  type        = string
  description = "Uniquely identifies the VPC."
}

variable "private_subnet_ids" {
  type        = list(any)
  description = "list of private subnet IDs to put the role provisioner and role checker lambda functions in"
}
