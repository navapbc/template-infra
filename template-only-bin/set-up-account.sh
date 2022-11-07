#!/bin/bash
set -euo pipefail

ACCOUNT=$1

echo "Account configuration"
echo "====================="
echo "ACCOUNT=$ACCOUNT"
echo

cd infra/accounts/$ACCOUNT

echo "--------------------"
echo "Initialize Terraform"
echo "--------------------"
terraform init

echo "-------------------------------"
echo "Deploy infrastructure resources"
echo "-------------------------------"

# Create the infrastructure for the terraform backend such as the S3 bucket
# for storing tfstate files and the DynamoDB table for tfstate locks.
terraform apply -auto-approve

echo "-------------------------------------------"
echo "Reconfigure Terraform backend to S3 backend"
echo "-------------------------------------------"

# Get the name of the S3 bucket that was created to store the tf state
# and the name of the DynamoDB table that was created for tf state locks.
# This will be used to configure the S3 backend in main.tf
TF_STATE_BUCKET_NAME=$(terraform output -raw tf_state_bucket_name)
TF_LOCKS_TABLE_NAME=$(terraform output -raw tf_locks_table_name)
REGION=$(terraform output -raw region)


# Configure the S3 backend in main.tf by replacing the placeholder
# values with the actual values from the previous step, then
# uncomment the S3 backend block
sed -i.bak "s/<TF_STATE_BUCKET_NAME>/$TF_STATE_BUCKET_NAME/" main.tf
sed -i.bak "s/<TF_LOCKS_TABLE_NAME>/$TF_LOCKS_TABLE_NAME/" main.tf
sed -i.bak "s/<REGION>/$REGION/" main.tf
sed -i.bak 's/#uncomment# //g' main.tf

echo "------------------------------"
echo "Copy tfstate to new S3 backend"
echo "------------------------------"

# Re-initialize terraform with the new backend and copy the tfstate
# to the new backend in S3
terraform init -force-copy
