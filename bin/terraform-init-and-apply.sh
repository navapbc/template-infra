#!/bin/bash
set -euo pipefail

MODULE_DIR="$1"
BACKEND_CONFIG_NAME="$2"
TF_APPLY_ARGS="${@:3}"

# Convenience script for running terraform init and terraform apply
# BACKEND_CONFIG_NAME – the name of the backend config.
# For example if a backend config file is named "myaccount.s3.tfbackend", then the BACKEND_CONFIG_NAME would be "myaccount"
# MODULE_DIR – the location of the root module to initialize and apply
# TF_APPLY_ARGS – any additional arguments to pass to terraform apply

BACKEND_CONFIG_FILE="$BACKEND_CONFIG_NAME.s3.tfbackend"

cd $MODULE_DIR

terraform init \
  -input=false \
  -reconfigure \
  -backend-config=$BACKEND_CONFIG_FILE

terraform apply $TF_APPLY_ARGS
