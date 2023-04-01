#!/bin/bash
set -euo pipefail

# APP_NAME is the name of the directory that holds the application code,
# as well as the subdirectory of /infra that holds the application
# infrastructure code. Defaults to "app".
APP_NAME=${1:-app}

# Set up tfvars file for the app build repository

REGION=$(terraform -chdir=infra/accounts output -raw region)

echo "==========================================="
echo "Setting up tfvars file for build-repository"
echo "==========================================="
echo "REGION=$REGION"

TF_VARS_FILE="infra/$APP_NAME/build-repository/terraform.tfvars"

cp infra/$APP_NAME/build-repository/example.tfvars $TF_VARS_FILE
sed -i.bak "s/<REGION>/$REGION/g" $TF_VARS_FILE
rm $TF_VARS_FILE.bak
