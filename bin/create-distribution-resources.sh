#!/bin/bash
set -euo pipefail

# APP_NAME is the name of the directory that holds the application code,
# as well as the subdirectory of /infra that holds the application
# infrastructure code. Defaults to "app".
APP_NAME=${1:-app}

# Get the GitHub action role arn from account module
GITHUB_ACTIONS_ROLE_ARN=$(terraform -chdir=infra/bootstrap/account output -raw github_actions_role_arn)

echo "Setup configuration"
echo "APP_NAME=$APP_NAME"
echo "GITHUB_ACTIONS_ROLE_ARN=$GITHUB_ACTIONS_ROLE_ARN"

cd infra/$APP_NAME/dist/

# Replace the placeholder values for terraform variables
sed -i .bak "s/<GITHUB_ACTIONS_ROLE_ARN>/$GITHUB_ACTIONS_ROLE_ARN/g" terraform.tfvars

# Initialize terraform
terraform init

# Create infra resources needed to manage built release candidates
terraform apply
