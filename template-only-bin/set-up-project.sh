#!/bin/bash
set -euo pipefail

PROJECT_NAME=$1
OWNER=$2
DEFAULT_REGION=$3
REPO_URL=$(git remote get-url origin)

echo "Account configuration"
echo "====================="
echo "PROJECT_NAME=$PROJECT_NAME"
echo "REPO_URL=$REPO_URL"
echo

cd infra/project-config

echo "-------------------------------------"
echo "Replace placeholder values in main.tf"
echo "-------------------------------------"

# First replace the placeholder value for <PROJECT_NAME> in main.tf
# The project name is used to define unique names for the infrastructure
# resources that are created in subsequent infra setup steps.
sed -i.bak "s/<PROJECT_NAME>/$PROJECT_NAME/" main.tf

# Then replace the placeholder value for <REPO_URL> in main.tf
# The repository is needed to set up the GitHub OpenID Connect provider
# in AWS which allows GitHub Actions to authenticate with our AWS account
# when called from our repository only.
# Use '|' as the regex delimeter for sed instead of '/' since
# REPO_URL will have a '/' in it
sed -i.bak "s|<REPO_URL>|$REPO_URL|" main.tf

# Replace remaining placeholder values
sed -i.bak "s/<OWNER>/$OWNER/" main.tf
sed -i.bak "s/<DEFAULT_REGION>/$DEFAULT_REGION/" main.tf

# Remove the backup file created by sed
rm main.tf.bak
