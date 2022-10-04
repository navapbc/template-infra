variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "github_repository" {
  type = string
  description = "The 'org/repo' string for the github repo. This is used to set up the GitHub OpenID Connect provider in AWS which allows GitHub Actions to authenticate with our AWS account when called from our repository only. Example: 'navapbc/template-infra'"
}
