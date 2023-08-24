#!/bin/bash
#
# This script updates template-infra in your project. Run
# This script from your project's root directory.
set -euo pipefail

set +e

# Delete ECS cluster
aws ecs delete-service --no-cli-pager --cluster app-dev --service app-dev --force
aws ecs delete-cluster --no-cli-pager --cluster app-dev

# Delete load balancers
LOAD_BALANCERS=$(aws elbv2 describe-load-balancers --no-cli-pager --query 'LoadBalancers[*].[LoadBalancerArn]' --output text)
for LOAD_BALANCER in $LOAD_BALANCERS; do
  echo "Deleting load balancer $LOAD_BALANCER"

  aws elbv2 delete-load-balancer --load-balancer-arn "$LOAD_BALANCER"
done


# Follow process in https://www.learnaws.org/2022/07/04/delete-versioning-bucket-s3/
BUCKETS=$(aws s3api list-buckets --no-cli-pager --query 'Buckets[*].[Name]' --output text)
for BUCKET in $BUCKETS; do
  echo "Deleting bucket $BUCKET"

  # Deleting all versioned objects
  aws s3api delete-objects --no-cli-pager --bucket $BUCKET --delete "$(aws s3api list-object-versions --bucket $BUCKET --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"

  # Deleting all delete markers
  aws s3api delete-objects --no-cli-pager --bucket $BUCKET --delete "$(aws s3api list-object-versions --bucket $BUCKET --query='{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}')"

  # Delete bucket
  aws s3api delete-bucket --no-cli-pager --bucket $BUCKET
done

# Delete log groups
LOG_GROUPS=$(aws logs describe-log-groups --no-cli-pager --query 'logGroups[*].[logGroupName]' --output text)
for LOG_GROUP in $LOG_GROUPS; do
  echo "Deleting log group $LOG_GROUP"
  aws logs delete-log-group --log-group-name "$LOG_GROUP"
done

aws iam delete-role --role-name app-dev
aws iam delete-role --role-name app-dev-task-executor

set -e


# security groups
# sns topic
# alerts
# iam roles
