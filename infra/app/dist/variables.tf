variable "github_actions_role_arn" {
  type        = string
  description = "The ARN of the role that GitHub actions assumes during workflows. This is used to allow GitHub actions to publish built release artifacts to the container image repository."
}

variable "app_environment_account_ids" {
  type        = list(string)
  description = "List of AWS account ids for the application's environments. This is used to allow environments pull images from the container image repository."
}
