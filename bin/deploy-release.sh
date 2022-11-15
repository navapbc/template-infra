#!/bin/bash
set -euo pipefail

APP_NAME=$1
IMAGE_TAG=$2
ENV_NAME=$3

ACCOUNT_ID=$(terraform -chdir=infra/$APP_NAME/envs/$ENV_NAME output -raw account_id)

echo "--------------------------"
echo "Deploy release parameters"
echo "--------------------------"
echo "APP_NAME=$APP_NAME"
echo "IMAGE_TAG=$IMAGE_TAG"
echo "IMAGE_NAME=$ENV_NAME"
echo "ACCOUNT_ID=$ACCOUNT_ID"
echo
echo "Deploy image to AWS"
terraform init
terraform -chdir=infra/$APP_NAME/envs/$ENV_NAME apply -auto-approve -var="image_tag=$IMAGE_TAG"
echo "Deployed $ENV_NAME to aws account $ACCOUNT_ID"
