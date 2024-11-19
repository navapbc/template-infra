locals {
  aws_services = [
    "acm",
    "apigateway",
    "application-autoscaling",
    "autoscaling",
    "backup",
    "cloudwatch",
    "cognito-idp",
    "dynamodb",
    "ec2",
    "ecr",
    "ecs",
    "elasticbeanstalk",
    "elasticloadbalancing",
    "events",
    "evidently",
    "iam",
    "kms",
    "lambda",
    "logs",
    "mobiletargeting", # this is pinpoint
    "pipes",
    "rds",
    "route53",
    "route53domains",
    "s3",
    "scheduler",
    "schemas",
    "secretsmanager",
    "servicediscovery",
    "ses",
    "sns",
    "ssm",
    "states",
    "waf-regional",
    "wafv2",
  ]
}
