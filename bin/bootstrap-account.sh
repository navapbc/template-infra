#!/bin/bash
set -euxo pipefail

# PROJECT_NAME defaults to name of the current directory.
# Run this at project root before changing directories
PROJECT_NAME=$(basename $(PWD))

# GITHUB_REPOSITORY defaults to the origin of the current git repo
# Get the URL string and remove the "git@github.com:" prefix, leaving
# just the "org/repo" string (e.g. "navapbc/template-infra")
GITHUB_REPOSITORY=$(git remote get-url origin | sed s/^git@github.com://)

cd infra/bootstrap/account

# Initialize terraform
terraform init

# First replace the placeholder value for <PROJECT_NAME> in main.tf
# The project name is used to define unique names for the infrastructure
# resources that are created in the subsequent steps.
sed -i .bak "s/<PROJECT_NAME>/$PROJECT_NAME/" main.tf

# Then replace the placeholder value for <GITHUB_REPOSITORY> in main.tf
# The repository name is used to set up the GitHub OpenID Connect provider
# in AWS which allows GitHub Actions to authenticate with our AWS account
# when called from our repository only.
# Use '|' as the regex delimeter for sed instead of '/' since
# GITHUB_REPOSITORY will have a '/' in it
sed -i .bak "s|<GITHUB_REPOSITORY>|$GITHUB_REPOSITORY|" main.tf


# Create the infrastructure for the terraform backend such as the S3 bucket
# for storing tfstate files and the DynamoDB table for tfstate locks.
terraform apply -auto-approve

# Get the name of the S3 bucket that was created to store the tf state
# and the name of the DynamoDB table that was created for tf state locks.
# This will be used to configure the S3 backend in main.tf
TF_STATE_BUCKET_NAME=$(terraform output -raw tf_state_bucket_name)
TF_LOCKS_TABLE_NAME=$(terraform output -raw tf_locks_table_name)

# Configure the S3 backend in main.tf by replacing the placeholder
# values with the actual values from the previous step, then
# uncomment the S3 backend block
sed -i .bak "s/<TF_STATE_BUCKET_NAME>/$TF_STATE_BUCKET_NAME/" main.tf
sed -i .bak "s/<TF_LOCKS_TABLE_NAME>/$TF_LOCKS_TABLE_NAME/" main.tf
sed -i .bak 's/#uncomment# //g' main.tf

# Re-initialize terraform with the new backend and copy the tfstate
# to the new backend in S3
terraform init -force-copy
