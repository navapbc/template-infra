#!/bin/bash
set -euo pipefail

APP_NAME=$1
IMAGE_TAG=$2
ENV_NAME=$3

echo "--------------------------"
echo "Deploy release parameters"
echo "--------------------------"
echo "APP_NAME=$APP_NAME"
echo "IMAGE_TAG=$IMAGE_TAG"
echo "IMAGE_NAME=$ENV_NAME"
echo
echo "Deploy image to AWS"
terraform -chdir=infra/$APP_NAME/envs/$ENV_NAME init
terraform -chdir=infra/$APP_NAME/envs/$ENV_NAME apply -auto-approve -var="image_tag=$IMAGE_TAG"
echo "Deploy success"
