variable "database_name" {
  description = "the name of the Postgres database. Defaults to 'app'."
  default     = "app"
  validation {
    condition     = can(regex("^[_\\da-z]+$", var.database_name))
    error_message = "use only lower case letters, numbers, and underscores (no dashes)"
  }
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

variable "network_name" {
  description = "The name of the network within which the database will run"
  type        = string
}

variable "port" {
  description = "value of the port on which the database accepts connections. Defaults to 5432."
  default     = 5432
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "database_insights_mode" {
  description = <<-EOT
    Database Insights mode for the cluster. Database Insights replaced
    Performance Insights, which AWS retired on 2026-07-31.

    - "standard" (default): free, 7-day retention.
    - "advanced": paid (priced per vCPU/month, plus API charges), long-term
      retention and SQL-level analysis. Advanced requires a retention period of
      at least 465 days.

    See https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/USER_DatabaseInsights.html
  EOT
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "advanced"], var.database_insights_mode)
    error_message = "database_insights_mode must be either \"standard\" or \"advanced\""
  }
}

variable "performance_insights_retention_period" {
  description = <<-EOT
    Days of Performance Insights history to retain. Defaults to null, which
    leaves whatever the cluster already has rather than changing it -- existing
    databases are commonly on a non-default value, and lowering this discards
    history irreversibly.

    When null, new clusters get the AWS default for the chosen
    database_insights_mode: 7 days for "standard", 465 for "advanced".

    Valid values are 7, 731, or a multiple of 31. "advanced" mode requires at
    least 465.
  EOT
  type        = number
  default     = null
  validation {
    condition = (
      var.performance_insights_retention_period == null ||
      var.performance_insights_retention_period == 7 ||
      var.performance_insights_retention_period == 731 ||
      (try(var.performance_insights_retention_period % 31, 1) == 0)
    )
    error_message = "performance_insights_retention_period must be 7, 731, or a multiple of 31"
  }
  validation {
    condition = (
      var.database_insights_mode != "advanced" ||
      var.performance_insights_retention_period == null ||
      var.performance_insights_retention_period >= 465
    )
    error_message = "advanced database_insights_mode requires a retention period of at least 465 days"
  }
}
