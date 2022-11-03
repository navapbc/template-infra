variable "github_actions_role_name" {
  type        = string
  description = "The name to use for the IAM role GitHub actions will assume."
}

variable "github_repository" {
  type        = string
  description = "The GitHub repository in 'org/repo' format to provide access to AWS account resources. Example: navapbc/template-infra"
}

variable "github_branch" {
  type        = string
  description = "The git refs of the GitHub repo to provide access to AWS account resources. Defaults to '*' which allows all branches. Example: refs/heads/main"
  default     = "*"
}

variable "iam_role_policy_arns" {
  type        = list(string)
  description = "List of IAM policy ARNs to attach to the GitHub Actions IAM role. Defaults to Developer power user access role."
  default     = ["arn:aws:iam::aws:policy/PowerUserAccess"]
}
