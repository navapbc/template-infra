#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This script destroys a network layer.
# Do not run this script if you still have app layers deployed in this network.
# Run this script in your project's root directory.
#
# Positional parameters:
#   NETWORK_NAME (optional) - the name of the network
#     Defaults to "dev".
# -----------------------------------------------------------------------------
set -euxo pipefail

NETWORK_NAME=${1:-"dev"}
BACKEND_CONFIG_FILE="${ENVIRONMENT_NAME}.s3.tfbackend"

cd infra/networks

terraform init -reconfigure -backend-config="${BACKEND_CONFIG_FILE}"

terraform destroy -auto-approve -var="network_name=${NETWORK_NAME}"
