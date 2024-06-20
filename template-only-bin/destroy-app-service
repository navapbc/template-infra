#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This script destroys the service layer for an application.
# Run this script in your project's root directory.
#
# Positional parameters:
#   APP_NAME (optional) - the name of the application directory in /infra
#     Defaults to "app".
#   ENVIRONMENT (optional) - the name of the environment
#     Defaults to "dev".
# -----------------------------------------------------------------------------
set -euxo pipefail

APP_NAME=${1:-"app"}
ENVIRONMENT=${2:-"dev"}
BACKEND_CONFIG_FILE="${ENVIRONMENT}.s3.tfbackend"

sed -i.bak 's/force_destroy = false/force_destroy = true/g' infra/modules/service/access-logs.tf
sed -i.bak 's/force_destroy = false/force_destroy = true/g' infra/modules/storage/main.tf
sed -i.bak 's/enable_deletion_protection = !var.is_temporary/enable_deletion_protection = false/g' infra/modules/service/load-balancer.tf

cd "infra/${APP_NAME}/service"

terraform init -reconfigure -backend-config="${BACKEND_CONFIG_FILE}"

terraform apply -auto-approve -target="module.service.aws_s3_bucket.access_logs" -target="module.service.aws_lb.alb" -var="environment_name=${ENVIRONMENT}"

terraform destroy -auto-approve -var="environment_name=${ENVIRONMENT}"
