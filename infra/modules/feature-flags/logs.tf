data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_cloudwatch_log_group" "logs" {
  # Prefix log group name with /aws/vendedlogs/ to handle situations where the resource policy
  # that AWS automatically creates to allow Evidently to send logs to CloudWatch exceeds the
  # 5120 character limit.
  # see https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AWS-logs-and-resource-policy.html#AWS-vended-logs-permissions
  # see https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_iam-quotas.html#reference_iam-quotas-entity-length
  #
  # Note that manually creating resource policies is also not ideal, as there is a quote of
  # up to 10 CloudWatch Logs resource policies per Region per account, which can't be changed.
  # see https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/cloudwatch_limits_cwl.html
  name = "/aws/vendedlogs/feature-flags/${local.evidently_project_name}"

  # checkov:skip=CKV_AWS_158:Feature flag evaluation logs are not sensitive

  # Conservatively retain logs for 5 years.
  # Looser requirements may allow shorter retention periods
  retention_in_days = 1827
}
