variable "tf_state_bucket" {
  description = "state bucket"
}

variable "aws_region" {
  description = "The region to deploy to"
}

variable "environment_name" {}

variable "db_master_password" {
  description = "Master password of the database, found in AWS Secrets Manager."
}

variable "db_users" {
  description = "Map of users to add to the postgres database"
  type        = any
  default     = {}
}
