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

./bin/terraform-init.sh $MODULE_DIR $CONFIG_NAME

./bin/terraform-apply.sh $MODULE_DIR $CONFIG_NAME $TF_APPLY_ARGS
