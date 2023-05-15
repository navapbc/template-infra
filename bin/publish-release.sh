#!/bin/bash

set -euo pipefail

APP_NAME=$1
IMAGE_NAME=$2
IMAGE_TAG=$3

# Need to init module when running in CD since GitHub actions does a fresh checkout of repo
./bin/terraform-init.sh infra/$APP_NAME/build-repository shared
REGION=$(terraform -chdir=infra/$APP_NAME/build-repository output -raw region)
IMAGE_REGISTRY=$(terraform -chdir=infra/$APP_NAME/build-repository output -raw image_registry)
IMAGE_REPOSITORY_URL=$(terraform -chdir=infra/$APP_NAME/build-repository output -raw image_repository_url)

echo "---------------"
echo "Publish release"
echo "---------------"
echo "Input parameters:"
echo "  APP_NAME=$APP_NAME"
echo "  IMAGE_NAME=$IMAGE_NAME"
echo "  IMAGE_TAG=$IMAGE_TAG"
echo "Build repository info:"
echo "  REGION=$REGION"
echo "  IMAGE_REGISTRY=$IMAGE_REGISTRY"
echo "  IMAGE_REPOSITORY_URL=$IMAGE_REPOSITORY_URL"
echo
echo "Authenticating Docker with ECR"
aws ecr get-login-password --region $REGION \
  | docker login --username AWS --password-stdin $IMAGE_REGISTRY
echo
echo "Check if tag has already been published..."
RESULT=""
RESULT=$(aws ecr describe-images --repository-name $IMAGE_NAME --image-ids imageTag=$IMAGE_TAG --region $REGION 2> /dev/null ) || true
if [ ! -z "$RESULT" ];then
  echo "Image with tag $IMAGE_TAG already published"
  exit 0
fi


echo "New tag. Publishing image"
docker tag $IMAGE_NAME:$IMAGE_TAG $IMAGE_REPOSITORY_URL:$IMAGE_TAG
docker push $IMAGE_REPOSITORY_URL:$IMAGE_TAG
