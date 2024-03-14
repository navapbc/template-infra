#!/bin/bash
# Do not use this script on your project. This script is only used for testing
# the platform bootstrap process.
set -euxo pipefail

BACKEND_CONFIG_FILE="dev.s3.tfbackend"

sed -i.bak 's/force_destroy = false/force_destroy = true/g' infra/modules/service/access-logs.tf
sed -i.bak 's/force_destroy = false/force_destroy = true/g' infra/modules/storage/main.tf
sed -i.bak 's/enable_deletion_protection = !var.is_temporary/enable_deletion_protection = false/g' infra/modules/service/load-balancer.tf

cd infra/app/service

terraform init -reconfigure -backend-config=$BACKEND_CONFIG_FILE

terraform apply -auto-approve -target="module.service.aws_s3_bucket.access_logs" -target="module.service.aws_lb.alb" -var="environment_name=dev"

terraform destroy -auto-approve -var="environment_name=dev"
