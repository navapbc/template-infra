#!/bin/bash
# -----------------------------------------------------------------------------
# This script sets up the terraform backend for the AWS account that you are
# currently authenticated into and creates the terraform backend config file.
#
# The script takes a human readable account name that is used to prefix the tfbackend
# file that is created. This is to make it easier to visually identify while
# tfbackend file corresponds to which AWS account. The account ID is still
# needed since all AWS accounts are guaranteed to have an account ID, and the
# account ID cannot change, whereas other things like the AWS account alias
# can change and is not guaranteed to exist.
#
# Positional parameters:
#   ACCOUNT_NAME (required) - human readable name for the AWS account that you're
#     authenticated into. The account name will be used to prefix the created
#     tfbackend file so that it's easier to visually identify as opposed to
#     identifying the file using the account id.
#     For example, you have an account per environment, the account name can be
#     the name of the environment (e.g. "prod" or "staging"). Or if you are
#     setting up an account for all lower environments, account name can be "lowers".
#     If your AWS account has an account alias, you can also use that.
# -----------------------------------------------------------------------------
set -euo pipefail

ACCOUNT_NAME=$1

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
echo "ACCOUNT_NAME=$ACCOUNT_NAME"
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
aws s3api create-bucket --bucket $TF_STATE_BUCKET_NAME --region $REGION --create-bucket-configuration LocationConstraint=$REGION > /dev/null
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
BACKEND_CONFIG_NAME="$ACCOUNT_NAME.$ACCOUNT_ID"
./bin/create-tfbackend.sh $MODULE_DIR $BACKEND_CONFIG_NAME $TF_STATE_KEY
