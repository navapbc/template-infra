#!/bin/bash
# Do not use this script on your project. This script is only used for testing
# the platform bootstrap process.
set -euxo pipefail

BACKEND_CONFIG_FILE="dev.s3.tfbackend"
TF_VARS_FILE="dev.tfvars"

cd infra/app/service

sed -i.bak 's/resource "aws_s3_bucket" "load_balancer_logs" {/&\n  force_destroy = true/' ../../infra/modules/service/main.tf

terraform init -reconfigure -backend-config=$BACKEND_CONFIG_FILE

terraform apply -auto-approve -var-file=$TF_VARS_FILE

terraform destroy -auto-approve -var-file=$TF_VARS_FILE
