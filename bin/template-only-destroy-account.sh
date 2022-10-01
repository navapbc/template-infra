#!/bin/bash
# Do not use this script on your project. This script is only used for testing
# the platform bootstrap process.
set -euxo pipefail

cd infra/bootstrap/account

cat ../../modules/bootstrap/main.tf \
  | sed 's/resource "aws_s3_bucket" "tf_state" {/&\n  force_destroy = true/' \
  | sed 's/resource "aws_s3_bucket" "tf_log" {/&\n  force_destroy = true/' \
  | sed 's/prevent_destroy = true/prevent_destroy = false/g' \
  > tmp.tf
mv tmp.tf ../../modules/bootstrap/main.tf

terraform apply -auto-approve

# Delete the backend s3 block
cat main.tf \
  | sed '{N;N;N;N;N;N;N;N;N;N;N;N;s/backend "s3" {.*}//;}' \
  > tmp.tf
mv tmp.tf main.tf

# Unconfigure S3 backend and move tfstate file to local tfstate
terraform init -force-copy

terraform destroy -auto-approve
