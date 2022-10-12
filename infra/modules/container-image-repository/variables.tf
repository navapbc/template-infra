variable "project_name" {
  type        = string
  description = "The name of the project. This will be used to prefix the name of the ECR repository."
}

variable "app_name" {
  type        = string
  description = "The name of the application. This will be used to prefix the name of the ECR repository."
}
