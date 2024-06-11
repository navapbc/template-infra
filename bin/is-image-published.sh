#!/bin/bash
# Checks if an image tag has already been published to the container repository
# Prints "true" if so, "false" otherwise

set -euo pipefail

app_name=$1
git_ref=$2

# Get commit hash
image_tag=$(git rev-parse "$git_ref")

# Need to init module when running in CD since GitHub actions does a fresh checkout of repo
terraform -chdir="infra/$app_name/app-config" init > /dev/null
terraform -chdir="infra/$app_name/app-config" apply -auto-approve > /dev/null
image_repository_name=$(terraform -chdir="infra/$app_name/app-config" output -raw image_repository_name)
region=$(./bin/current-region.sh)

result=""
result=$(aws ecr describe-images --repository-name "$image_repository_name" --image-ids "imageTag=$image_tag" --region "$region" 2> /dev/null ) || true
if [ -n "$result" ];then
  echo "true"
else
  echo "false"
fi
