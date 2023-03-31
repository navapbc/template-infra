#!/bin/bash
set -euo pipefail

# Name the account based on the current account alias
ACCOUNT="$(./bin/current-account-alias.sh)"
REGION="$(./bin/current-region.sh)"
BACKEND_CONFIG_FILE="$ACCOUNT.s3.tfbackend"

# Get project name
terraform -chdir=infra/project-config refresh > /dev/null
PROJECT_NAME=$(terraform -chdir=infra/project-config output -raw project_name)

TF_STATE_BUCKET_NAME="$PROJECT_NAME-$ACCOUNT-$REGION-tf"

echo "=================="
echo "Setting up account"
echo "=================="
echo "ACCOUNT=$ACCOUNT"
echo "REGION=$REGION"
echo

echo "------------------------------------------------------------------------------"
echo "Bootstrapping the account by creating an S3 backend with minimal configuration"
echo "------------------------------------------------------------------------------"
echo 
echo "Creating bucket: $TF_STATE_BUCKET_NAME"
aws s3api create-bucket --bucket $TF_STATE_BUCKET_NAME --region $REGION > /dev/null
echo

echo "----------------------------------"
echo "Creating rest of account resources"
echo "----------------------------------"
echo 

cd infra/accounts

# Create the infrastructure for the terraform backend such as the S3 bucket
# for storing tfstate files and the DynamoDB table for tfstate locks.
terraform init \
  -input=false \
  -backend-config="bucket=$TF_STATE_BUCKET_NAME" \
  -backend-config="region=$REGION"

# Import the S3 bucket that was created in the previous step so we don't recreate it
terraform import module.backend.aws_s3_bucket.tf_state $TF_STATE_BUCKET_NAME

terraform apply \
  -input=false \
  -auto-approve

cd -

echo "-----------------------------------"
echo "Creating backend configuration file"
echo "-----------------------------------"
echo "BACKEND_CONFIG_FILE=$BACKEND_CONFIG_FILE"
echo

cd infra/accounts

cp example.s3.tfbackend $BACKEND_CONFIG_FILE

# Get the name of the S3 bucket that was created to store the tf state
# and the name of the DynamoDB table that was created for tf state locks.
# This will be used to configure the S3 backend in main.tf
TF_STATE_BUCKET_NAME=$(terraform output -raw tf_state_bucket_name)
TF_LOCKS_TABLE_NAME=$(terraform output -raw tf_locks_table_name)
REGION=$(terraform output -raw region)

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
