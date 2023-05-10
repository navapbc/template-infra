#!/bin/bash
# Do not use this script on your project. This script is only used for testing
# the platform bootstrap process.
set -euxo pipefail

CONFIG_NAME="$(./bin/current-account-config-name.sh)"
BACKEND_CONFIG_FILE="$CONFIG_NAME.s3.tfbackend"

cd infra/accounts

# The following lines update S3 buckets in the terraform bootstrap module
# add force_destroy = true to S3 resource blocks and update any lifecycle
# prevent_destroy = true rules to false. The reason we need to do this is
# because S3 buckets by default are protected from destruction to avoid
# loss of data. See [Terraform: Destroy/Replace Buckets](https://medium.com/interleap/terraform-destroy-replace-buckets-cf9d63d0029d)
# for a more in depth explanation.
sed -i.bak 's/resource "aws_s3_bucket" "tf_state" {/&\n  force_destroy = true/' ../modules/terraform-backend-s3/main.tf
sed -i.bak 's/resource "aws_s3_bucket" "tf_log" {/&\n  force_destroy = true/' ../modules/terraform-backend-s3/main.tf
sed -i.bak 's/prevent_destroy = true/prevent_destroy = false/g' ../modules/terraform-backend-s3/main.tf

terraform init -reconfigure -backend-config=$BACKEND_CONFIG_FILE

# Apply the S3 bucket changes from the previous step
terraform apply -auto-approve

# Delete the backend S3 block to re-configure terraform to use local state
# since we're about to delete the backend S3 bucket. The following sed command
# deletes every line between 'backend "s3" {' and '}'
sed -i.bak '{/backend "s3" {/,/}/d;}' main.tf

# Now re-initialize terraform to unconfigure the S3 backend and
# move the tfstate file to a local tfstate file
terraform init -force-copy

# Finally destroy the infrastructure
terraform destroy -auto-approve
