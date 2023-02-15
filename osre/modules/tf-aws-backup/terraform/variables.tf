variable "environment_name" {}
variable "aws_region" {}

variable "application_name" {
  description = "App name to distinguish resources"
  type = string
}

variable "resource_arns" {
  description = "List of ARNs for resources to backup"
  type = list(string)
}

variable "schedule" {
  description = "Cron schedule to run backups (evaluated UTC)"
  type = string
  default = "0 5 1-31/2 * ? *" # Midnight EST, on odd-numbered days, every month, any day-of-week, every year
}

variable "retention" {
  description = "Number of days to preserve backups"
  type = number
  default = 14
}

variable "notifications_sns_topic_arn" {
  description = "SNS Topic ARN to receive notifications, see notifications.tf for current event list"
  type = string
  default = null
}