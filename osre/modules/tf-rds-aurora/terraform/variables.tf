variable "environment_name" {}
variable "vpc_id" {}
variable "vpc_name" {}

variable "application_name" {
  type        = string
  description = "The name of the application"
}

variable "cloudwatch_notification_arn" {
  type        = string
  description = "The notification ARN to send CloudWatch alarms"
}

variable "parameter_group_name_override" {
  description = "The name of the parameter group created in this module (default is the same as the DB cluster name)"
  default     = ""
}

variable "cluster_parameters" {
  default     = {}
  description = <<DESC
    Map of parameters to attach to cluster parameter group. Format should be
    {
      param1 = {
        value = "bar",
        apply_method = "pending-reboot"
      }

      param2 = {
        value = "foo"
      }
    }

    default apply_method is "immediate" if null.
  DESC
}

variable "instance_count" {
  type        = number
  # > 1 will create reader nodes and a reader endpoint
  description = "Number of DB instances for the Aurora cluster"
  default     = 1
}

variable "backup_retention_period" {
  type        = string
  description = "The backup retention period in days"
}

variable "database_name" {
  type        = string
  description = "The name of the DB to create. Leaving the name as an empty string will create an RDS instance without a specific DB. See https://www.terraform.io/docs/providers/aws/r/db_instance.html#name for more detail"
  default     = ""
}

variable "engine" {
  type        = string
  description = "The database engine"
}

variable "engine_version" {
  type        = string
  description = "The database engine version"
}

variable "iam_database_authentication_enabled" {
  type        = bool
  description = "Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled"
  default     = true
}

variable "db_port" {
  type        = string
  description = "The port the db uses."
}

variable "snapshot_identifier" {
  type        = string
  description = "Specifies whether or not to create this database from a snapshot. This correlates to the snapshot ID you'd find in the RDS console, e.g: rds:production-2015-06-26-06-05."
  default     = ""
}

variable "subnet_ids" {
  type        = list(any)
  description = "List of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group"
}

variable "security_group_ids" {
  type        = list(any)
  description = "Security groups permitted to access RDS."
  default     = []
}

variable "master_username" {
  type        = string
  description = "The username for the master DB user."
}

variable "ingress_cidrs" {
  type        = list(any)
  description = "List of cidrs allowed access to cluster"
  default     = []
}

variable "update_password" {
  type        = bool
  default     = true
  description = "Whether to update the master password when instance is created"
}

variable "enable_pg_cron" {
  type        = bool
  default     = false
  description = "Enable pg_cron_plugin for Aurora database"
}

variable "performance_insights_enabled" {
  description = "Specifies whether performance Insight is enabled"
  type        = bool
  default     = false
}

variable "performance_insights_retention_period" {
  description = "The retention period of performance insight data"
  type        = string
  default     = 7
}

// CloudWatch alarm if CPU utilization for writer >= 90%
variable "writer_cpu_utilization" {
  description = "Parameters for writer_cpu_utilization Cloudwatch metric alarm"
  type        = map(any)
  default = {
    "comparison_operator" = "GreaterThanOrEqualToThreshold"
    "evaluation_periods"  = "2"
    "period"              = "300"
    "statistic"           = "Average"
    "threshold"           = "90"
    "datapoints_to_alarm" = null
  }
}

// CloudWatch alarm if CPU utilization for reader >= 90%
variable "reader_cpu_utilization" {
  description = "Parameters for reader_cpu_utilization Cloudwatch metric alarm"
  type        = map(any)
  default = {
    "comparison_operator" = "GreaterThanOrEqualToThreshold"
    "evaluation_periods"  = "2"
    "period"              = "300"
    "statistic"           = "Average"
    "threshold"           = "90"
    "datapoints_to_alarm" = null
  }
}

variable "restore_to_point_in_time" {
  description = <<DESC
    If provided, creates a brand new cloned copy of the cluster, at the specified point in time.
    Example:
      restore_to_point_in_time = {
        restore_to_time            = "2022-10-11T16:00:00Z"
        source_cluster_identifier  = module.mpsmcd_2616_rds_aurora.cluster_resource_id
        use_latest_restorable_time = false
      }
  DESC
  type = object({
    restore_to_time            = string
    source_cluster_identifier  = string
    use_latest_restorable_time = bool
  })

  default = null
}

variable "serverlessv2_scaling_configuration" {
  description = <<DESC
    If provided, will create a Serverless V2 cluster, or convert an existing cluster to Serverless V2.
    Example:
      serverlessv2_scaling_configuration = {
        max_capacity  = 128.0
        min_capacity  = 0.5
      }
  DESC
  type = object({
    max_capacity = number
    min_capacity = number
  })
}
