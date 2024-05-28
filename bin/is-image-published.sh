#!/bin/bash
# Checks if an image tag has already been published to the container repository
# Prints "true" if so, "false" otherwise

set -euo pipefail

APP_NAME=$1
GIT_REF=$2

# Get commit hash
IMAGE_TAG=$(git rev-parse "$GIT_REF")

# Need to init module when running in CD since GitHub actions does a fresh checkout of repo
terraform -chdir="infra/$APP_NAME/app-config" init > /dev/null
terraform -chdir="infra/$APP_NAME/app-config" apply -auto-approve > /dev/null
IMAGE_REPOSITORY_NAME=$(terraform -chdir="infra/$APP_NAME/app-config" output -raw image_repository_name)
REGION=$(./bin/current-region.sh)

RESULT=""
RESULT=$(aws ecr describe-images --repository-name "$IMAGE_REPOSITORY_NAME" --image-ids "imageTag=$IMAGE_TAG" --region "$REGION" 2> /dev/null ) || true
if [ -n "$RESULT" ];then
  echo "true"
else
  echo "false"
fi
