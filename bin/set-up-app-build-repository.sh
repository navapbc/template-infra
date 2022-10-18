#!/bin/bash
set -euo pipefail

PROJECT_NAME=$1
APP_NAME=${2:-app}

echo "Setup configuration"
echo "PROJECT_NAME=$PROJECT_NAME"
echo "APP_NAME=$APP_NAME"

echo "Setting up build-repository"

cd infra/$APP_NAME/build-repository
terraform init
terraform apply -auto-approve
