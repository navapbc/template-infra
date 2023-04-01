#!/bin/bash
set -euo pipefail

# APP_NAME is the name of the directory that holds the application code,
# as well as the subdirectory of /infra that holds the application
# infrastructure code. Defaults to "app".
APP_NAME=${1:-app}

# Get project name
terraform -chdir=infra/project-config refresh > /dev/null
PROJECT_NAME=$(terraform -chdir=infra/project-config output -raw project_name)

# The list of modules we need to set up
SHARED_MODULES="build-repository"

PER_ENVIRONMENT_MODULES="service"

ENVIRONMENTS="\
  dev \
  staging \
  prod \
  "

# Get the name of the S3 bucket that was created to store the tf state
# and the name of the DynamoDB table that was created for tf state locks.
# This will be used to configure the S3 backends in all the application
# modules
TF_STATE_BUCKET_NAME=$(terraform -chdir=infra/accounts output -raw tf_state_bucket_name)
TF_LOCKS_TABLE_NAME=$(terraform -chdir=infra/accounts output -raw tf_locks_table_name)
REGION=$(terraform -chdir=infra/accounts output -raw region)

echo "====================================="
echo "Setting up terraform backends for app"
echo "====================================="
echo "PROJECT_NAME=$PROJECT_NAME"
echo "APP_NAME=$APP_NAME"
echo "TF_STATE_BUCKET_NAME=$TF_STATE_BUCKET_NAME"
echo "TF_LOCKS_TABLE_NAME=$TF_LOCKS_TABLE_NAME"
echo "REGION=$REGION"

function set_up_backend_config_file() {
  echo "----------------------------"
  echo "Creating backend config file"
  echo "----------------------------"
  echo "BACKEND_CONFIG_FILE=$BACKEND_CONFIG_FILE"

  cp infra/example.s3.tfbackend $BACKEND_CONFIG_FILE

  # Replace the placeholder values in the module
  sed -i.bak "s/<TF_STATE_BUCKET_NAME>/$TF_STATE_BUCKET_NAME/g" $BACKEND_CONFIG_FILE
  sed -i.bak "s|<TF_STATE_KEY>|$TF_STATE_KEY|g" $BACKEND_CONFIG_FILE
  sed -i.bak "s/<TF_LOCKS_TABLE_NAME>/$TF_LOCKS_TABLE_NAME/g" $BACKEND_CONFIG_FILE
  sed -i.bak "s/<REGION>/$REGION/g" $BACKEND_CONFIG_FILE
}

echo "Setting up modules for resources that are shared between environments"
for MODULE in ${SHARED_MODULES[*]}
do
  BACKEND_CONFIG_FILE="infra/$APP_NAME/$MODULE/shared.s3.tfbackend"
  TF_STATE_KEY="infra/$APP_NAME/$MODULE.tfstate"
  set_up_backend_config_file
done

echo "Setting up modules for resources that are separate for each environments"
for MODULE in ${PER_ENVIRONMENT_MODULES[*]}
do
  for ENVIRONMENT in ${ENVIRONMENTS[*]}
  do
    BACKEND_CONFIG_FILE="infra/$APP_NAME/$MODULE/$ENVIRONMENT.s3.tfbackend"
    TF_STATE_KEY="infra/$APP_NAME/environments/$ENVIRONMENT.tfstate"
    set_up_backend_config_file
  done
done
