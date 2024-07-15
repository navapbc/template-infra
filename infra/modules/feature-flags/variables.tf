variable "feature_flags" {
  type        = set(string)
  description = "A set of feature flag names"
}

variable "service_name" {
  type        = string
  description = "The name of the service that the feature flagging system will be associated with"
}
