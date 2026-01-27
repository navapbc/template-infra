variable "is_temporary" {
  description = "Whether the service is meant to be spun up temporarily (e.g. for automated infra tests). This is used to disable deletion protection."
  type        = bool
  default     = false
}

variable "name" {
  type        = string
  description = "Name of the AWS S3 bucket. Needs to be globally unique across all regions."
}

variable "use_aws_managed_encryption" {
  description = "Use AWS-managed encryption (AES256) instead of customer-managed KMS keys"
  type        = bool
  default     = false
}
