#!/bin/bash
set -euo pipefail

# Name the account based on the current account alias
ACCOUNT_ALIAS="$(./bin/current-account-alias.sh)"
ACCOUNT_ID="$(./bin/current-account-id.sh)"
REGION="$(./bin/current-region.sh)"

# Get project name
terraform -chdir=infra/project-config refresh > /dev/null
PROJECT_NAME=$(terraform -chdir=infra/project-config output -raw project_name)

TF_STATE_BUCKET_NAME="$PROJECT_NAME-$ACCOUNT_ID-$REGION-tf"
TF_STATE_KEY="infra/account.tfstate"

echo "=================="
echo "Setting up account"
echo "=================="
echo "ACCOUNT_ALIAS=$ACCOUNT_ALIAS"
echo "ACCOUNT_ID=$ACCOUNT_ID"
echo "PROJECT_NAME=$PROJECT_NAME"
echo "TF_STATE_BUCKET_NAME=$TF_STATE_BUCKET_NAME"
echo "TF_STATE_KEY=$TF_STATE_KEY"
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
# -reconfigure is used in case this isn't the first account being set up
# and there is already a .terraform directory
terraform init \
  -reconfigure \
  -input=false \
  -backend-config="bucket=$TF_STATE_BUCKET_NAME" \
  -backend-config="key=$TF_STATE_KEY" \
  -backend-config="region=$REGION"

# Import the S3 bucket that was created in the previous step so we don't recreate it
terraform import module.backend.aws_s3_bucket.tf_state $TF_STATE_BUCKET_NAME


# Wrap terraform apply in a retry loop.
#
# This is a workaround to a race condition that seems to have been recently introduced
# by AWS S3 and at the time of writing (2023-05-09) has yet to be resolved.
# See https://github.com/hashicorp/terraform-provider-aws/issues/31139 for more details
# about the issue.
# There is an outstanding PR in the Terraform AWS provider created on Apr 24, 2023 that
# may resolve this issue: https://github.com/hashicorp/terraform-provider-aws/pull/30916
#
# Once the issue is resolved, this retry loop can be removed and we can run terraform apply
# directly.
MAX_RETRIES=5

# Define the command to execute
COMMAND="terraform apply \
  -input=false \
  -auto-approve"

# Loop until the command succeeds or the maximum number of retries is reached
for i in $(seq 1 $MAX_RETRIES); do
  if $COMMAND; then
    break
  else
    echo "Terraform apply failed. Sleeping and retrying..."
    sleep 3
  fi
done


cd -

MODULE_DIR=infra/accounts
BACKEND_CONFIG_NAME=$ACCOUNT_ALIAS
./bin/create-tfbackend.sh $MODULE_DIR $BACKEND_CONFIG_NAME $TF_STATE_KEY
