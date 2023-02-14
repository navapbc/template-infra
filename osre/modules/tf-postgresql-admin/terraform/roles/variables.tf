variable "admin_user" {
  description = "The master (admin) user of the database"
  type        = string
}

variable "db_host" {
  description = "The hostname of the database"
  type        = string
}

variable "pg_password" {
  description = "The password of the master user"
  type        = string
}

variable "db_name" {
  description = "The database name of the RDS instance/cluster"
  type        = string
}

variable "secret_namespace" {
  description = "The secret namespace where a new secret is defined"
  type        = string
}

variable "secret_name" {
  description = "An existing secret in Secrets Manager"
  type        = string
  default     = ""
}

variable "name" {
  description = "The name of the user/role to be created"
  type        = string
}

variable "login" {
  description = "Whether the db role should have the ability to log in to the DB"
  type        = bool
  default     = false
}

variable "roles" {
  description = "List of roles to grant the new user/role"
  type        = list(any)
  default     = []
}

variable "secrets_manager_kms_key" {
  description = "KMS key to be used to encrypt secret values"
}
