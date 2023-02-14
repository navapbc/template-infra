variable "aws_region" {
  description = "AWS Region"
}

variable "environment_name" {
}

variable "admin_user" {
  description = "Name of the master (admin) user"
}

variable "db_host" {
  description = "Database host"
}

variable "pg_password" {
  description = "Password of the master user"
}

variable "db_name" {
  description = "Database of the RDS instance/cluster"
}

variable "secret_namespace" {
  description = "Secret namespace where new secret will be created"
}

variable "db_users" {
  description = "Map of users to add to the postgres database"
  type        = any
  default     = {}
}

variable "create_dmod_user" {
  description = "Whether to create the DMOD user in this database"
  type        = bool
  default     = false
}

variable "create_nessus_user" {
  description = "Whether to create the nessusdb user in this database"
  type        = bool
  default     = false
}

variable "secrets_manager_kms_key" {
  description = "KMS key to be used to encrypt secret values"
}
