variable "is_temporary" {
  description = "Whether the service is meant to be spun up temporarily (e.g. for automated infra tests). This is used to disable deletion protection."
  type        = bool
  default     = false
}

variable "name" {
  type        = string
  description = "Name of the AWS S3 bucket. Needs to be globally unique across all regions."
}

variable "service_principals_with_access" {
  description = "List of AWS service principals that should have access to the S3 bucket via KMS (e.g., bedrock.amazonaws.com)"
  type        = list(string)
  default     = []
}
