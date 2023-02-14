variable "tf_state_bucket" {
  description = "state bucket"
}

variable "aws_region" {
  description = "The region to deploy to"
}

variable "vpc_name" {
  description = "The name of the vpc"
}

variable "vpc_type" {
  description = "the type of the vpc"
}

variable "environment_name" {
  description = "The name of the environment"
}

variable "snapshot_identifier" {
  default     = ""
  description = "The snapshot identifier name"
}

variable "instance_count" {
  type        = number
  description = "Number of DB instances for the Aurora cluster"
  default     = 1
}

variable "ingress_cidrs" {
  type        = list(any)
  description = "List of cidrs allowed access to cluster"
  default     = ["10.232.32.0/19"]
}

variable "allow_gdit_vpn_access" {
  description = "Boolean value determining if the GDIT cidr should be allowed"
  default     = false
}

variable "update_password" {
  type        = bool
  default     = false
  description = "Whether to update the master password when instance is created"
}

variable "db_engine_version" {
  description = "The engine version of the RDS instance"
  type        = string
  default     = "13.6"
}

variable "db_engine_major_version" {
  description = "The major version of the of the RDS instance"
  type        = string
  default     = "13"
}

variable "enable_pg_cron" {
  type        = bool
  default     = false
  description = "Enable pg_cron extention for Aurora DB"
}

variable "performance_insights_enabled" {
  description = "Specifies whether performance Insight is enabled"
  type        = bool
  default     = false
}
