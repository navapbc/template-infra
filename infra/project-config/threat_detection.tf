locals {
  # Whether to enable the Threat Detection detector for the account
  # Finding publishing frequency must be one of: FIFTEEN_MINUTES, ONE_HOUR, SIX_HOURS.
  enable_threat_detection                       = true
  threat_detection_finding_publishing_frequency = "FIFTEEN_MINUTES"
}
