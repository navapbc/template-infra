#!/bin/bash
set -euo pipefail

# MODULE_DIR is the directory of the root module that will be configured
MODULE_DIR=$1

# BACKEND_CONFIG_NAME is the name of the backend that will be created.
# For environment specific configs, the BACKEND_CONFIG_NAME will be the same
# as ENVIRONMENT. For shared configs, the BACKEND_CONFIG_NAME will be "shared".
BACKEND_CONFIG_NAME=$2

# TF_STATE_KEY is the S3 object key of the tfstate file in the S3 bucket
# It is an optional parameter that defaults to [MODULE_DIR]/[BACKEND_CONFIG_NAME].tfstate
TF_STATE_KEY="${3:-$MODULE_DIR/$BACKEND_CONFIG_NAME.tfstate}"

# The local tfbackend config file that will store the terraform backend config
BACKEND_CONFIG_FILE="$MODULE_DIR/$BACKEND_CONFIG_NAME.s3.tfbackend"

# Get the name of the S3 bucket that was created to store the tf state
# and the name of the DynamoDB table that was created for tf state locks.
# This will be used to configure the S3 backends in all the application
# modules
TF_STATE_BUCKET_NAME=$(terraform -chdir=infra/accounts output -raw tf_state_bucket_name)
TF_LOCKS_TABLE_NAME=$(terraform -chdir=infra/accounts output -raw tf_locks_table_name)
REGION=$(terraform -chdir=infra/accounts output -raw region)

echo "================================================================"
echo "Creating terraform backend config file for terraform root module"
echo "================================================================"
echo "Input parameters"
echo "  MODULE_DIR=$MODULE_DIR"
echo "  BACKEND_CONFIG_NAME=$BACKEND_CONFIG_NAME"
echo

# Create output file from example file
cp infra/example.s3.tfbackend $BACKEND_CONFIG_FILE

# Replace the placeholder values
sed -i.bak "s/<TF_STATE_BUCKET_NAME>/$TF_STATE_BUCKET_NAME/g" $BACKEND_CONFIG_FILE
sed -i.bak "s|<TF_STATE_KEY>|$TF_STATE_KEY|g" $BACKEND_CONFIG_FILE
sed -i.bak "s/<TF_LOCKS_TABLE_NAME>/$TF_LOCKS_TABLE_NAME/g" $BACKEND_CONFIG_FILE
sed -i.bak "s/<REGION>/$REGION/g" $BACKEND_CONFIG_FILE

# Remove the backup file created by sed
rm $BACKEND_CONFIG_FILE.bak


echo "Created file: $BACKEND_CONFIG_FILE"
echo "---------------------- start ----------------------"
cat $BACKEND_CONFIG_FILE
echo "----------------------- end -----------------------"
