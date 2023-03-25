#!/bin/bash
set -euo pipefail

# Name the account based on the current account alias
ACCOUNT="$(aws iam list-account-aliases --query "AccountAliases" --max-items 1 --output text)"
BACKEND_CONFIG_FILE=$ACCOUNT.s3.tfbackend

echo "====================================="
echo "Setting up account $ACCOUNT"
echo "====================================="

echo "-------------------------------------------------"
echo "Bootstrapping the account by creating the backend"
echo "-------------------------------------------------"

cd infra/accounts/bootstrap

# Create the infrastructure for the terraform backend such as the S3 bucket
# for storing tfstate files and the DynamoDB table for tfstate locks.
terraform init -input=false
terraform apply -input=false -auto-approve

# Get the name of the S3 bucket that was created to store the tf state
# and the name of the DynamoDB table that was created for tf state locks.
# This will be used to configure the S3 backend in main.tf
TF_STATE_BUCKET_NAME=$(terraform output -raw tf_state_bucket_name)
TF_LOCKS_TABLE_NAME=$(terraform output -raw tf_locks_table_name)
REGION=$(terraform output -raw region)

# Cleanup local tfstate
rm -fr .terraform*
cd -

echo "-------------------------------------------------------------------"
echo "Creating backend configuration file $BACKEND_CONFIG_FILE"
echo "-------------------------------------------------------------------"

cd infra/accounts

cp example.s3.tfbackend $BACKEND_CONFIG_FILE

# Configure the S3 backend in main.tf by replacing the placeholder
# values with the actual values from the previous step, then
# uncomment the S3 backend block
sed -i.bak "s/<TF_STATE_BUCKET_NAME>/$TF_STATE_BUCKET_NAME/" $BACKEND_CONFIG_FILE
sed -i.bak "s/<TF_LOCKS_TABLE_NAME>/$TF_LOCKS_TABLE_NAME/" $BACKEND_CONFIG_FILE
sed -i.bak "s/<REGION>/$REGION/" $BACKEND_CONFIG_FILE
sed -i.bak 's/#uncomment# //g' $BACKEND_CONFIG_FILE

# Cleanup backup file created by sed
rm $BACKEND_CONFIG_FILE.bak

cd -
