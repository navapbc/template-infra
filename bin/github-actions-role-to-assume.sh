#!/bin/bash
# -----------------------------------------------------------------------------
# Print the IAM role that GitHub Actions needs to assume for the associated
# application environment. This is used by GitHub Actions workflows.
#
# An alternative approach would be to leverage GitHub Environments variables,
# but not all projects have access to GitHub environments.
#
# Positional parameters:
#   APP_NAME (required) – the name of subdirectory of /infra that holds the
#     application's infrastructure code.
#   ENVIRONMENT is the name of the application environment (e.g. dev, staging, prod)
# -----------------------------------------------------------------------------
set -euo pipefail

APP_NAME="$1"
ENVIRONMENT="$2"

# This file defines variables for each environment e.g.
#   dev=...
#   prod=...
# where the value of each variable is an IAM role ARN
source infra/$APP_NAME/app-config/github-actions-role-to-assume.ini

# Evaluate the variable with the name given by $ENVIRONMENT.
# So if $ENVIRONMENT = "dev", then let ROLE_TO_ASSUME_ARN=$dev
ROLE_ARN=${!ENVIRONMENT:-}

if [ -z $ROLE_ARN ]; then
  echo "No role defined for environment: $ENVIRONMENT" >&2
  exit 1
fi

echo -n $ROLE_ARN
