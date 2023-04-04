#!/bin/bash
# Do not use this script on your project. This script is only used for testing
# the platform bootstrap process.
set -euxo pipefail

BACKEND_CONFIG_FILE="shared.s3.tfbackend"

cd infra/app/build-repository

terraform init -reconfigure -backend-config=$BACKEND_CONFIG_FILE

terraform destroy -auto-approve
