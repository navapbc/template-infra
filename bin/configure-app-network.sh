#!/bin/bash
# -----------------------------------------------------------------------------
# This script configures the network module for the specified application
# and environment by creating the .tfvars file and .tfbackend file for the module.
#
# Positional parameters:
#   APP_NAME (required) – the name of subdirectory of /infra that holds the
#     application's infrastructure code.
#   ENVIRONMENT is the name of the application environment (e.g. dev, staging, prod)
# -----------------------------------------------------------------------------
set -euo pipefail

APP_NAME=$1
ENVIRONMENT=$2

#--------------------------------------
# Create terraform backend config file
#--------------------------------------

MODULE_DIR="infra/$APP_NAME/network"
CONFIG_NAME=$ENVIRONMENT

./bin/create-tfbackend.sh $MODULE_DIR $CONFIG_NAME

#--------------------
# Create tfvars file
#--------------------

TF_VARS_FILE="$MODULE_DIR/$CONFIG_NAME.tfvars"

# Get the name of the S3 bucket that was created to store the tf state
# and the name of the DynamoDB table that was created for tf state locks.
# This will be used to configure the S3 backends in all the application
# modules
REGION=$(terraform -chdir=infra/accounts output -raw region)


echo "======================================"
echo "Setting up tfvars file for app service"
echo "======================================"
echo "Input parameters"
echo "  ENVIRONMENT=$ENVIRONMENT"
echo

cp $MODULE_DIR/example.tfvars $TF_VARS_FILE
sed -i.bak "s/<REGION>/$REGION/g" $TF_VARS_FILE
rm $TF_VARS_FILE.bak

echo "Created file: $TF_VARS_FILE"
echo "------------------ file contents ------------------"
cat $TF_VARS_FILE
echo "----------------------- end -----------------------"
