#!/bin/bash
#
# This script updates template-infra in your project. Run
# This script from your project's root directory.
set -euo pipefail

BUCKETS=$(aws s3api list-buckets --no-cli-pager --query 'Buckets[*].Name' --output text)

set +e

# Delete ECS cluster
aws ecs delete-service --no-cli-pager --cluster app-dev --service app-dev --force
aws ecs delete-cluster --no-cli-pager --cluster app-dev

# Follow process in https://www.learnaws.org/2022/07/04/delete-versioning-bucket-s3/
for BUCKET in $BUCKETS; do
  echo "Deleting $BUCKET"

  # Deleting all versioned objects
  aws s3api delete-objects --no-cli-pager --bucket $BUCKET --delete "$(aws s3api list-object-versions --bucket $BUCKET --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"

  # Deleting all delete markers
  aws s3api delete-objects --no-cli-pager --bucket $BUCKET --delete "$(aws s3api list-object-versions --bucket $BUCKET --query='{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}')"

  # Delete bucket
  aws s3api delete-bucket --no-cli-pager --bucket $BUCKET
done

set -e


# load balancers
# security groups
# sns topic
# alerts
# log groups
# iam roles
