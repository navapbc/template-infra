variable "name" {
  description = "name of the database cluster. Note that this is not the name of the Postgres database itself, but the name of the cluster in RDS. The name of the Postgres database is set in module and defaults to 'app'."
  type        = string
  validation {
    condition     = can(regex("^[-_\\da-z]+$", var.name))
    error_message = "use only lower case letters, numbers, dashes, and underscores"
  }
}

variable "app_access_policy_name" {
  description = "name of the IAM policy to create that will provide the service the ability to connect to the database as a user that will have read/write access."
  type        = string
}

variable "migrator_access_policy_name" {
  description = "name of the IAM policy to create that will provide the migration task the ability to connect to the database as a user that will have read/write access."
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

variable "schema_name" {
  description = "name of the Postgres schema to create that will be the schema the application will use (rather than using the public schema)"
  type        = string
  validation {
    condition     = can(regex("^[_\\da-z]+$", var.schema_name))
    error_message = "use only lower case letters, numbers, and underscores (no dashes)"
  }
}

variable "port" {
  description = "value of the port on which the database accepts connections. Defaults to 5432."
  default     = 5432
}

variable "database_name" {
  description = "the name of the Postgres database. Defaults to 'app'."
  default     = "app"
  validation {
    condition     = can(regex("^[_\\da-z]+$", var.database_name))
    error_message = "use only lower case letters, numbers, and underscores (no dashes)"
  }
}

variable "vpc_id" {
  type        = string
  description = "Uniquely identifies the VPC."
}

variable "database_subnet_group_name" {
  type        = string
  description = "Name of database subnet group"
}

variable "private_subnet_ids" {
  type        = list(any)
  description = "list of private subnet IDs to put the role provisioner and role checker lambda functions in"
}

variable "aws_services_security_group_id" {
  type        = string
  description = "Security group ID for VPC endpoints that access AWS Services"
}
