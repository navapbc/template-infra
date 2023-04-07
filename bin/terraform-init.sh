#!/bin/bash
set -euo pipefail

MODULE_DIR="$1"
CONFIG_NAME="$2"

# Convenience script for running terraform init
# CONFIG_NAME – the name of the backend config.
# For example if a backend config file is named "myaccount.s3.tfbackend", then the CONFIG_NAME would be "myaccount"
# MODULE_DIR – the location of the root module to initialize and apply

# 1. Set working directory to the terraform root module directory

cd $MODULE_DIR

# 2. Run terraform init with the named backend config file

BACKEND_CONFIG_FILE="$CONFIG_NAME.s3.tfbackend"

terraform init \
  -input=false \
  -reconfigure \
  -backend-config=$BACKEND_CONFIG_FILE
