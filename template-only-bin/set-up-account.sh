#!/bin/bash
set -euo pipefail

PROJECT_NAME=$1
ACCOUNT=$2

# GITHUB_REPOSITORY defaults to the origin of the current git repo
# Get the "org/repo" string (e.g. "navapbc/template-infra") by first
# getting the repo URL (e.g. "git@github.com:navapbc/template-infra.git"
# or "https://github.com/navapbc/template-infra.git"), getting the
# repo name (e.g. "template-infra"), then searching with grep for the
# string that includes both the repo name and the org name before it.
REPO_URL=$(git remote get-url origin)
REPO_NAME=$(basename $REPO_URL .git)
GITHUB_REPOSITORY=$(echo $REPO_URL | \
    grep --extended-regexp --only-matching "[-_a-zA-Z0-9]+/$REPO_NAME")

echo "Account configuration"
echo "====================="
echo "PROJECT_NAME=$PROJECT_NAME"
echo "ACCOUNT=$ACCOUNT"
echo "REPO_URL=$REPO_URL"
echo "REPO_NAME=$REPO_NAME"
echo "GITHUB_REPOSITORY=$GITHUB_REPOSITORY"
echo

cd infra/accounts/$ACCOUNT

echo "--------------------"
echo "Initialize Terraform"
echo "--------------------"
terraform init

echo "-------------------------------------"
echo "Replace placeholder values in main.tf"
echo "-------------------------------------"

# First replace the placeholder value for <PROJECT_NAME> in main.tf
# The project name is used to define unique names for the infrastructure
# resources that are created in the subsequent steps.
#
# Then replace the placeholder value for <GITHUB_REPOSITORY> in main.tf
# The repository name is used to set up the GitHub OpenID Connect provider
# in AWS which allows GitHub Actions to authenticate with our AWS account
# when called from our repository only.
# Use '|' as the regex delimeter for sed instead of '/' since
# GITHUB_REPOSITORY will have a '/' in it
cp main.tf main.tf.bak
cat main.tf.bak \
    | sed "s/<PROJECT_NAME>/$PROJECT_NAME/" \
    | sed "s|<GITHUB_REPOSITORY>|$GITHUB_REPOSITORY|" \
    > main.tf

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

# Configure the S3 backend in main.tf by replacing the placeholder
# values with the actual values from the previous step, then
# uncomment the S3 backend block
cp main.tf main.tf.bak
cat main.tf.bak \
    | sed "s/<TF_STATE_BUCKET_NAME>/$TF_STATE_BUCKET_NAME/" \
    | sed "s/<TF_LOCKS_TABLE_NAME>/$TF_LOCKS_TABLE_NAME/" \
    | sed 's/#uncomment# //g' \
    > main.tf

echo "------------------------------"
echo "Copy tfstate to new S3 backend"
echo "------------------------------"

# Re-initialize terraform with the new backend and copy the tfstate
# to the new backend in S3
terraform init -force-copy
