#!/bin/bash
# -----------------------------------------------------------------------------
# Configure GitHub Actions to assume the given IAM role for a particular
# environment.
#
# Positional parameters:
#   APP_NAME (required) – the name of subdirectory of /infra that holds the
#     application's infrastructure code.
#   ENVIRONMENT (required) – the name of the application environment,
#     (e.g. dev, staging, prod), or "shared" for resources that are shared
#     across environments
# -----------------------------------------------------------------------------
set -euo pipefail

APP_NAME="$1"
ENVIRONMENT="$2"

CONFIG_FILE=infra/$APP_NAME/app-config/github-actions-role-to-assume.ini

terraform -chdir=infra/project-config refresh > /dev/null
PROJECT_NAME=$(terraform -chdir=infra/project-config output -raw project_name)
ACCOUNT_ID=$(./bin/current-account-id.sh)
ROLE_ARN="arn:aws:iam::$ACCOUNT_ID:role/$PROJECT_NAME-github-actions"

echo "========================================"
echo "Set up role-to-assume for GitHub Actions"
echo "========================================"
echo "Input parameters"
echo "  APP_NAME=$APP_NAME"
echo "  ENVIRONMENT=$ENVIRONMENT"
echo
echo "Target configuration"
echo "  ROLE_ARN=$ROLE_ARN"
echo
# Remove any existing configuration for the environment
sed -i.bak "/$ENVIRONMENT=/d" $CONFIG_FILE
rm $CONFIG_FILE.bak

# Add new configuration
echo "$ENVIRONMENT=\"$ROLE_ARN\"" >> $CONFIG_FILE

# Sort the file
sort $CONFIG_FILE > sorted-config && mv sorted-config $CONFIG_FILE

# Show result
echo "Configured roles:"
echo "-----------------"
cat $CONFIG_FILE
