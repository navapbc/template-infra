#!/bin/bash
set -euo pipefail

PROJECT_NAME=$1
ACCOUNT=${2:-account}
APP_NAME=${3:-app}

# Get the github actions role ARN from the account
GITHUB_ACTIONS_ROLE_ARN=$(terraform -chdir=infra/accounts/$ACCOUNT output -raw github_actions_role_arn)

echo "Setup configuration"
echo "PROJECT_NAME=$PROJECT_NAME"
echo "APP_NAME=$APP_NAME"
echo "GITHUB_ACTIONS_ROLE_ARN=$GITHUB_ACTIONS_ROLE_ARN"

echo "Setting up build-repository"

cd infra/$APP_NAME/build-repository

echo "----------------------------------------------"
echo "Replace placeholder values in terraform.tfvars"
echo "----------------------------------------------"

# Replace placeholder value of GitHub actions role with actual value
# Use '|' as sed command separator since role ARN can have '/' characters
cp terraform.tfvars terraform.tfvars.bak
cat terraform.tfvars.bak \
  | sed "s|<GITHUB_ACTIONS_ROLE_ARN>|$GITHUB_ACTIONS_ROLE_ARN|g"
  > terraform.tfvars

echo "-------------------------------"
echo "Deploy infrastructure resources"
echo "-------------------------------"

terraform init
terraform apply -auto-approve
