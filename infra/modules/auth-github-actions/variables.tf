variable "project_name" {
  type        = string
  description = "The name of the project. This will be used to prefix the names of the bootstrap resources."
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
  description = "List of IAM policy ARNs to attach to the GitHub Actions IAM role."
  default     = ["arn:aws:iam::aws:policy/PowerUserAccess"]
}
