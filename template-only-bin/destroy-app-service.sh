#!/bin/bash
# Do not use this script on your project. This script is only used for testing
# the platform bootstrap process.
set -euxo pipefail

BACKEND_CONFIG_FILE="dev.s3.tfbackend"
TF_VARS_FILE="dev.tfvars"

sed -i.bak 's/force_destroy = false/force_destroy = true/g' infra/modules/service/access_logs.tf

cd infra/app/service

terraform init -reconfigure -backend-config=$BACKEND_CONFIG_FILE

terraform apply -auto-approve -var-file=$TF_VARS_FILE

terraform destroy -auto-approve -var-file=$TF_VARS_FILE
