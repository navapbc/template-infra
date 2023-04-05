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
TF_STATE_KEY="infra/accounts.tfstate"

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
  -backend-config="key=$TF_STATE_KEY" \
  -backend-config="region=$REGION"

# Import the S3 bucket that was created in the previous step so we don't recreate it
terraform import module.backend.aws_s3_bucket.tf_state $TF_STATE_BUCKET_NAME

terraform apply \
  -input=false \
  -auto-approve

cd -

MODULE_DIR=infra/accounts
BACKEND_CONFIG_NAME=$ACCOUNT
./bin/create-tfbackend.sh $MODULE_DIR $BACKEND_CONFIG_NAME
