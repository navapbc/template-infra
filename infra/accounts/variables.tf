variable "enable_threat_detection" {
  description = "Whether to enable the ThreatDetection detector for the account"
  type        = bool
  default     = true
}

variable "threat_detection_finding_publishing_frequency" {
  description = "The frequency of notifications sent for subsequent ThreatDetection finding occurrences"
  type        = string
  default     = "FIFTEEN_MINUTES"

  validation {
    condition = contains([
      "FIFTEEN_MINUTES",
      "ONE_HOUR",
      "SIX_HOURS"
    ], var.threat_detection_finding_publishing_frequency)
    error_message = "Finding publishing frequency must be one of: FIFTEEN_MINUTES, ONE_HOUR, SIX_HOURS."
  }
}