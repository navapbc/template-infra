#!/bin/bash
set -euo pipefail

MODULE_DIR="$1"
CONFIG_NAME="$2"
TF_APPLY_ARGS="${@:3}"

# Convenience script for running terraform init and terraform apply
# CONFIG_NAME – the name of the backend config.
# For example if a backend config file is named "myaccount.s3.tfbackend", then the CONFIG_NAME would be "myaccount"
# MODULE_DIR – the location of the root module to initialize and apply
# TF_APPLY_ARGS – any additional arguments to pass to terraform apply

# 1. Set working directory to the terraform root module directory

cd $MODULE_DIR

# 2. Run terraform init with the named backend config file

BACKEND_CONFIG_FILE="$CONFIG_NAME.s3.tfbackend"

terraform init \
  -input=false \
  -reconfigure \
  -backend-config=$BACKEND_CONFIG_FILE

# 3. Run terraform apply with the tfvars file (if it exists) that has the same name as the backend config file

TF_VARS_FILE="$CONFIG_NAME.tfvars"
TF_VARS_OPTION=""
if [ -f $TF_VARS_FILE ]; then
  TF_VARS_OPTION="-var-file=$TF_VARS_FILE"
fi

terraform apply \
  $TF_VARS_OPTION \
  $TF_APPLY_ARGS
