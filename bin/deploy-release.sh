#!/bin/bash
set -euo pipefail

APP_NAME=$1
IMAGE_TAG=$2
ENV_NAME=$3

# Need to init module when running in CD since GitHub actions does a fresh checkout of repo
terraform -chdir=infra/$APP_NAME/envs/$ENV_NAME init
ACCOUNT_ID=$(terraform -chdir=infra/$APP_NAME/envs/$ENV_NAME output -raw account_id)

echo "--------------------------"
echo "Deploy release parameters"
echo "--------------------------"
echo "APP_NAME=$APP_NAME"
echo "IMAGE_TAG=$IMAGE_TAG"
echo "ENV_NAME=$ENV_NAME"
echo "ACCOUNT_ID=$ACCOUNT_ID"
echo
echo "Starting $APP_NAME deploy of $IMAGE_TAG to $ENV_NAME"
terraform -chdir=infra/$APP_NAME/envs/$ENV_NAME apply -auto-approve -var="image_tag=$IMAGE_TAG"
echo "Completed $APP_NAME deploy of $IMAGE_TAG to $ENV_NAME"
