variable "aws_services_security_group_id" {
  type        = string
  description = "Security group ID for VPC endpoints that access AWS Services"
}

variable "database_name" {
  description = "the name of the Postgres database. Defaults to 'app'."
  default     = "app"
  validation {
    condition     = can(regex("^[_\\da-z]+$", var.database_name))
    error_message = "use only lower case letters, numbers, and underscores (no dashes)"
  }
}

variable "database_subnet_group_name" {
  type        = string
  description = "Name of database subnet group"
}

variable "is_temporary" {
  description = "Whether the service is meant to be spun up temporarily (e.g. for automated infra tests). This is used to disable deletion protection."
  type        = bool
  default     = false
}

variable "name" {
  description = "name of the database cluster. Note that this is not the name of the Postgres database itself, but the name of the cluster in RDS. The name of the Postgres database is set in module and defaults to 'app'."
  type        = string
  validation {
    condition     = can(regex("^[-_\\da-z]+$", var.name))
    error_message = "use only lower case letters, numbers, dashes, and underscores"
  }
}

variable "port" {
  description = "value of the port on which the database accepts connections. Defaults to 5432."
  default     = 5432
}

variable "private_subnet_ids" {
  type        = list(any)
  description = "list of private subnet IDs to put the role provisioner and role checker lambda functions in"
}

variable "vpc_id" {
  type        = string
  description = "Uniquely identifies the VPC."
}
