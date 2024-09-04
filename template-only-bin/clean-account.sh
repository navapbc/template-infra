#!/bin/bash
set -uo pipefail
set +e

# Delete ECS cluster
aws ecs delete-service --no-cli-pager --cluster app-dev --service app-dev --force
aws ecs delete-cluster --no-cli-pager --cluster app-dev

# Delete load balancers
LOAD_BALANCERS=$(aws elbv2 describe-load-balancers --no-cli-pager --query 'LoadBalancers[*].[LoadBalancerArn]' --output text)
while IFS= read -r LOAD_BALANCER; do
    echo "Deleting load balancer $LOAD_BALANCER"
    aws elbv2 modify-load-balancer-attributes --no-cli-pager --load-balancer-arn "$LOAD_BALANCER" --attributes Key=deletion_protection.enabled,Value=false
    aws elbv2 delete-load-balancer --load-balancer-arn "$LOAD_BALANCER"
done <<< "$LOAD_BALANCERS"

# Delete log groups
# Delete ECS cluster first to prevent new log groups from being created
LOG_GROUPS=$(aws logs describe-log-groups --no-cli-pager --query 'logGroups[*].[logGroupName]' --output text)
while IFS= read -r LOG_GROUP; do
    echo "Deleting log group $LOG_GROUP"
    aws logs delete-log-group --log-group-name "$LOG_GROUP"
done <<< "$LOG_GROUPS"

# Delete SNS topics
SNS_TOPICS=$(aws sns list-topics --no-cli-pager --query 'Topics[*].[TopicArn]' --output text)
while IFS= read -r SNS_TOPIC; do
  echo "Deleting SNS topic $SNS_TOPIC"
  aws sns delete-topic --topic-arn "$SNS_TOPIC"
done <<< "$SNS_TOPICS"

# Delete alarms
ALARMS=$(aws cloudwatch describe-alarms --no-cli-pager --query 'MetricAlarms[*].[AlarmName]' --output text)
while IFS= read -r ALARM; do
    echo "Deleting CloudWatch alarm $ALARM"
    aws cloudwatch delete-alarms --alarm-names "$ALARM"
done <<< "$ALARMS"

# Delete feature flags
EVIDENTLY_PROJECTS=$(aws evidently list-projects --no-cli-pager --query 'projects[*].[name]' --output text)
while IFS= read -r EVIDENTLY_PROJECT; do
  echo "Deleting Evidently project $EVIDENTLY_PROJECT"

  FEATURES=$(aws evidently list-features --project "$EVIDENTLY_PROJECT" --no-cli-pager --query 'features[*].[name]' --output text)
  while IFS= read -r FEATURE; do
    echo "Deleting feature $FEATURE for project $EVIDENTLY_PROJECT"
    aws evidently delete-feature --feature "$FEATURE" --project "$EVIDENTLY_PROJECT"
  done <<< "$FEATURES"

  aws evidently delete-project --project "$EVIDENTLY_PROJECT"
done <<< "$EVIDENTLY_PROJECTS"

# Delete security groups
SECURITY_GROUPS=$(aws ec2 describe-security-groups --no-cli-pager --query 'SecurityGroups[*].[GroupId]' --output text)
while IFS= read -r SECURITY_GROUP; do
    echo "Deleting security group $SECURITY_GROUP"
    aws ec2 delete-security-group --group-id "$SECURITY_GROUP"
done <<< "$SECURITY_GROUPS"

# Delete IAM policies
# --scope Local = customer managed policies
POLICIES=$(aws iam list-policies --no-cli-pager --scope Local --query 'Policies[*].[Arn]' --output text)
while IFS= read -r POLICY; do
    echo "Deleting IAM policy $POLICY"

    # Detach policy from entities first
    ROLES=$(aws iam list-entities-for-policy --policy-arn "$POLICY" --no-cli-pager --query 'PolicyRoles[*].[RoleName]' --output text)
    while IFS= read -r ROLE; do
        echo "Detaching policy $POLICY from role $ROLE"
        aws iam detach-role-policy --policy-arn "$POLICY" --role-name "$ROLE"
    done <<< "$ROLES"

    aws iam delete-policy --policy-arn "$POLICY"
done <<< "$POLICIES"

# Delete IAM roles
# Must delete policies first
echo "Deleting role app-dev-app"
aws iam delete-role --role-name app-dev-app
echo "Deleting role app-dev-events"
aws iam delete-role --role-name app-dev-events
echo "Deleting role app-dev-scheduler"
aws iam delete-role --role-name app-dev-scheduler
echo "Deleting role app-dev-workflow-orchestrator"
aws iam delete-role --role-name app-dev-workflow-orchestrator
echo "Deleting role app-dev-task-executor"
# Must delete inline policies first
aws iam delete-role-policy --role-name app-dev-task-executor --policy-name app-dev-task-executor-role-policy
aws iam delete-role --role-name app-dev-task-executor

# Follow process in https://www.learnaws.org/2022/07/04/delete-versioning-bucket-s3/
BUCKETS=$(aws s3api list-buckets --no-cli-pager --query 'Buckets[*].[Name]' --output text)
while IFS= read -r BUCKET; do
  if ! aws s3api head-bucket --bucket "$BUCKET" 2>/dev/null; then
      # Bucket doesn't exist, continue to the next iteration
      echo "Bucket $BUCKET does not exist"
      continue
  fi

  echo "Deleting bucket $BUCKET"

  # Deleting all versioned objects
  aws s3api delete-objects --no-cli-pager --bucket "$BUCKET" --delete "$(aws s3api list-object-versions --bucket "$BUCKET" --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"

  # Deleting all delete markers
  aws s3api delete-objects --no-cli-pager --bucket "$BUCKET" --delete "$(aws s3api list-object-versions --bucket "$BUCKET" --query='{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}')"

  # Delete bucket
  aws s3api delete-bucket --no-cli-pager --bucket "$BUCKET"
done <<< "$BUCKETS"
