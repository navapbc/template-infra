variable "enable_detector" {
  description = "Whether to enable the GuardDuty detector"
  type        = bool
  default     = true
}

variable "finding_publishing_frequency" {
  description = "The frequency of notifications sent for subsequent finding occurrences"
  type        = string
  default     = "FIFTEEN_MINUTES"

  validation {
    condition = contains([
      "FIFTEEN_MINUTES",
      "ONE_HOUR",
      "SIX_HOURS"
    ], var.finding_publishing_frequency)
    error_message = "Finding publishing frequency must be one of: FIFTEEN_MINUTES, ONE_HOUR, SIX_HOURS."
  }
}

# TODO: When upgrading to AWS provider >= 5.7.0, uncomment for multi-region support:
# Ticket: https://github.com/navapbc/template-infra/issues/1004#issue-4083076747
# variable "regions" {
#   description = <<-EOF
#   List of AWS regions that GuardDuty should be enabled in.
#   This should typically include all regions that are being used in the project,
#   especially if there are resources in those regions that GuardDuty can monitor for security threats.
#   EOF
#   type        = list(string)
#   default     = []
# }