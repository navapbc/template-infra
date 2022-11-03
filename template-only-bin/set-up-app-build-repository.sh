#!/bin/bash
set -euo pipefail

PROJECT_NAME=$1
ACCOUNT=${2:-account}
APP_NAME=${3:-app}

echo "Setup configuration"
echo "PROJECT_NAME=$PROJECT_NAME"
echo "APP_NAME=$APP_NAME"

echo "Setting up build-repository"

cd infra/$APP_NAME/build-repository

echo "-------------------------------"
echo "Deploy infrastructure resources"
echo "-------------------------------"

terraform init
terraform apply -auto-approve
