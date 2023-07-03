locals {
  # Machine readable project name (lower case letters, dashes, and underscores)
  # This will be used in names of AWS resources
  project_name = "<PROJECT_NAME>"

  # Project owner
  owner = "<OWNER>"

  # URL of project source code repository
  code_repository_url = "<REPO_URL>"

  # Default AWS region for project (e.g. us-east-1, us-east-2, us-west-1)
  default_region = "<DEFAULT_REGION>"

  github_actions_role_name = "${local.project_name}-github-actions"

  # Map of app names to the associated configuration for the app
  app_configs = {
    app = module.app_config
  }
}

module "app_config" {
  source       = "../app/app-config"
  project_name = local.project_name
}

