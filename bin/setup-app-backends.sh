#!/bin/bash
set -euo pipefail

# PROJECT_NAME defaults to name of the current directory.
# Run this at project root before changing directories
PROJECT_NAME=$(basename $(PWD))

# APP_NAME is the name of the directory that holds the application code,
# as well as the subdirectory of /infra that holds the application
# infrastructure code. Defaults to "app".
APP_NAME=${1:-app}

# Get list of environments
ENVIRONMENTS=$(ls infra/app/envs)

# The list of modules we need to set up are all the environment modules
# as well as the individual modules for infrastructure resources that
# are shared across environments such as the dist module which contains
# infra resources for storing built release candidate artifacts used
# for deploying to all the environments
MODULES="dist ${ENVIRONMENTS[*]}"

# Get the name of the S3 bucket that was created to store the tf state
# and the name of the DynamoDB table that was created for tf state locks.
# This will be used to configure the S3 backends in all the application
# modules
TF_STATE_BUCKET_NAME=$(terraform -chdir=infra/bootstrap/account output -raw tf_state_bucket_name)
TF_LOCKS_TABLE_NAME=$(terraform -chdir=infra/bootstrap/account output -raw tf_locks_table_name)

echo "Setup configuration"
echo "PROJECT_NAME=$PROJECT_NAME"
echo "APP_NAME=$APP_NAME"
echo "TF_STATE_BUCKET_NAME=$TF_STATE_BUCKET_NAME"
echo "TF_LOCKS_TABLE_NAME=$TF_LOCKS_TABLE_NAME"

for MODULE in ${MODULES[*]}
do
  echo "Setting up $MODULE"

  # Replace the placeholder values in the module
  sed -i .bak "s/<PROJECT_NAME>/$PROJECT_NAME/g" infra/$MODULE/main.tf
  sed -i .bak "s/<APP_NAME>/$APP_NAME/g" infra/$MODULE/main.tf
  sed -i .bak "s/<TF_STATE_BUCKET_NAME>/$TF_STATE_BUCKET_NAME/g" infra/$MODULE/main.tf
  sed -i .bak "s/<TF_LOCKS_TABLE_NAME>/$TF_LOCKS_TABLE_NAME/g" infra/$MODULE/main.tf
done
