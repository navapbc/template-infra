locals {
  # The prefix key/value pair is used for Terraform Workspaces, which is useful for projects with multiple infrastructure developers.
  # By default, Terraform creates a workspace named “default.” If a non-default workspace is not created this prefix will equal “default”,
  # if you choose not to use workspaces set this value to "dev"
  prefix = terraform.workspace == "default" ? "" : "${terraform.workspace}-"

  # Database names should not contain dashes, but can contain underscores.
  database_safe_app_name = replace(var.app_name, "-", "_")

  bucket_name = "${local.prefix}${var.project_name}-${var.app_name}-${var.environment}"
}
