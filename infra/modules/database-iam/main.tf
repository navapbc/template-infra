data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_rds_cluster" "db" {
  cluster_identifier = var.name
}
locals {
  db_user_arn_prefix = "arn:aws:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:${data.aws_rds_cluster.db.cluster_resource_id}"
}
# Role that AWS Backup uses to authenticate when backing up the target resource
resource "aws_iam_role" "db_backup_role" {
  name_prefix        = "${var.name}-db-backup-role-"
  assume_role_policy = data.aws_iam_policy_document.db_backup_policy.json
}

data "aws_iam_policy_document" "db_backup_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "db_backup_role_policy_attachment" {
  role       = aws_iam_role.db_backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

#----------------------------------#
# IAM role for enhanced monitoring #
#----------------------------------#

resource "aws_iam_role" "rds_enhanced_monitoring" {
  name_prefix        = "${var.name}-enhanced-monitoring-"
  assume_role_policy = data.aws_iam_policy_document.rds_enhanced_monitoring.json
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

data "aws_iam_policy_document" "rds_enhanced_monitoring" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

# Role Manager Lambda Function Roles

resource "aws_iam_role" "role_manager" {
  name                = "${var.name}-manager"
  assume_role_policy  = data.aws_iam_policy_document.role_manager_assume_role.json
  managed_policy_arns = [data.aws_iam_policy.lambda_vpc_access.arn]
}

data "aws_iam_policy_document" "role_manager_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# AWS managed policy required by Lambda functions in order to access VPC resources
# see https://docs.aws.amazon.com/lambda/latest/dg/configuration-vpc.html
data "aws_iam_policy" "lambda_vpc_access" {
  name = "AWSLambdaVPCAccessExecutionRole"
}



data "aws_kms_key" "default_ssm_key" {
  key_id = "alias/aws/ssm"
}

data "aws_ssm_parameter" "random_db_password" {
  name = "/db/${var.name}/master-password"
}

resource "aws_iam_role_policy" "ssm_access" {
  name = "${var.name}-role-manager-ssm-access"
  role = aws_iam_role.role_manager.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ssm:GetParameter*"]
        Resource = "${data.aws_ssm_parameter.random_db_password.arn}"
      },
      {
        Effect   = "Allow"
        Action   = ["kms:Decrypt"]
        Resource = [data.aws_kms_key.default_ssm_key.arn]
      }
    ]
  })
}

# Authentication
# --------------

resource "aws_iam_policy" "db_access" {
  name   = var.access_policy_name
  policy = data.aws_iam_policy_document.db_access.json
}

data "aws_iam_policy_document" "db_access" {
  # Policy to allow connection to RDS via IAM database authentication
  # which is more secure than traditional username/password authentication
  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.IAMPolicy.html
  statement {
    actions = [
      "rds-db:connect"
    ]

    resources = [
      "${local.db_user_arn_prefix}/${var.app_username}",
      "${local.db_user_arn_prefix}/${var.migrator_username}",
    ]
  }
}
