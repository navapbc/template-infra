#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This script destroys the build repository layer for an application.
# Do not run this script if you still have app database or service layers deployed.
# Run this script in your project's root directory.
#
# Positional parameters:
#   APP_NAME (optional) - the name of the application directory in /infra
#     Defaults to "app".
# -----------------------------------------------------------------------------
set -euxo pipefail

APP_NAME=${1:-"app"}
BACKEND_CONFIG_FILE="shared.s3.tfbackend"

cd "infra/${APP_NAME}/build-repository"

terraform init -reconfigure -backend-config="${BACKEND_CONFIG_FILE}"

terraform destroy -auto-approve
