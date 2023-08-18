data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
module "database-networking" {
  source = "../database-networking"
}
module "database-iam" {
  source = "../database-iam"
}
module "database-monitoring" {
  source = "../database-monitoring"
}

locals {
  master_username       = "postgres"
  primary_instance_name = "${var.name}-primary"
  role_manager_name     = "${var.name}-role-manager"
  role_manager_package  = "${path.root}/role_manager.zip"

  # The ARN that represents the users accessing the database are of the format: "arn:aws:rds-db:<region>:<account-id>:dbuser:<resource-id>/<database-user-name>""
  # See https://aws.amazon.com/blogs/database/using-iam-authentication-to-connect-with-pgadmin-amazon-aurora-postgresql-or-amazon-rds-for-postgresql/
  db_user_arn_prefix = "arn:aws:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_rds_cluster.db.cluster_resource_id}"
}

# Database Configuration
# ----------------------

resource "aws_rds_cluster" "db" {
  # checkov:skip=CKV2_AWS_27:have concerns about sensitive data in logs; want better way to get this information
  # checkov:skip=CKV2_AWS_8:TODO add backup selection plan using tags

  # cluster identifier is a unique identifier within the AWS account
  # https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.CreateInstance.html
  cluster_identifier = var.name

  engine            = "aurora-postgresql"
  engine_mode       = "provisioned"
  database_name     = var.database_name
  port              = var.port
  master_username   = local.master_username
  master_password   = aws_ssm_parameter.random_db_password.value
  storage_encrypted = true
  kms_key_id        = aws_kms_key.db.arn

  # checkov:skip=CKV_AWS_128:Auth decision needs to be ironed out
  # checkov:skip=CKV_AWS_162:Auth decision needs to be ironed out
  iam_database_authentication_enabled = true
  deletion_protection                 = true
  copy_tags_to_snapshot               = true
  # final_snapshot_identifier = "${var.name}-final"
  skip_final_snapshot = true

  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }

  vpc_security_group_ids = [aws_security_group.db.id]

  enabled_cloudwatch_logs_exports = ["postgresql"]
}

resource "aws_rds_cluster_instance" "primary" {
  identifier                 = local.primary_instance_name
  cluster_identifier         = aws_rds_cluster.db.id
  instance_class             = "db.serverless"
  engine                     = aws_rds_cluster.db.engine
  engine_version             = aws_rds_cluster.db.engine_version
  auto_minor_version_upgrade = true
  monitoring_role_arn        = module.database-iam.role_manager_monitoring_arn
  monitoring_interval        = 30
}

resource "random_password" "random_db_password" {
  length = 48
  # Remove '@' sign from allowed characters since only printable ASCII characters besides '/', '@', '"', ' ' may be used.
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_ssm_parameter" "random_db_password" {
  name  = "/db/${var.name}/master-password"
  type  = "SecureString"
  value = random_password.random_db_password.result
}

resource "aws_kms_key" "db" {
  description         = "Key for RDS cluster ${var.name}"
  enable_key_rotation = true
}


# Database Backups
# ----------------

# Backup plan that defines when and how to backup and which backup vault to store backups in
# See https://docs.aws.amazon.com/aws-backup/latest/devguide/about-backup-plans.html
resource "aws_backup_plan" "backup_plan" {
  name = "${var.name}-db-backup-plan"

  rule {
    rule_name         = "${var.name}-db-backup-rule"
    target_vault_name = aws_backup_vault.backup_vault.name
    schedule          = "cron(0 7 ? * SUN *)" # Run Sundays at 12pm (EST)
  }
}

# Backup vault that stores and organizes backups
# See https://docs.aws.amazon.com/aws-backup/latest/devguide/vaults.html
resource "aws_backup_vault" "backup_vault" {
  name        = "${var.name}-db-backup-vault"
  kms_key_arn = data.aws_kms_key.backup_vault_key.arn
}

# KMS Key for the vault
# This key was created by AWS by default alongside the vault
data "aws_kms_key" "backup_vault_key" {
  key_id = "alias/aws/backup"
}

# Backup selection defines which resources to backup
# See https://docs.aws.amazon.com/aws-backup/latest/devguide/assigning-resources.html
# and https://docs.aws.amazon.com/aws-backup/latest/devguide/API_BackupSelection.html
resource "aws_backup_selection" "db_backup" {
  name         = "${var.name}-db-backup"
  plan_id      = aws_backup_plan.backup_plan.id
  iam_role_arn = module.database-iam.backup_role_arn

  resources = [
    aws_rds_cluster.db.arn
  ]
}

# Query Logging -> database-monitoring
# -------------

resource "aws_rds_cluster_parameter_group" "rds_query_logging" {
  name        = var.name
  family      = "aurora-postgresql13"
  description = "Default cluster parameter group"

  parameter {
    name = "log_statement"
    # Logs data definition statements (e.g. DROP, ALTER, CREATE)
    value = "ddl"
  }

  parameter {
    name = "log_min_duration_statement"
    # Logs all statements that run 100ms or longer
    value = "100"
  }
}

# Role Manager Lambda Function
# ----------------------------
#
# Resources for the lambda function that is used for managing database roles
# This includes creating and granting permissions to roles
# as well as viewing existing roles

resource "aws_lambda_function" "role_manager" {
  function_name = local.role_manager_name

  filename         = local.role_manager_package
  source_code_hash = data.archive_file.role_manager.output_base64sha256
  runtime          = "python3.9"
  handler          = "role_manager.lambda_handler"
  role             = module.database-iam.role_manager_arn
  kms_key_arn      = aws_kms_key.role_manager.arn

  # Only allow 1 concurrent execution at a time
  reserved_concurrent_executions = 1

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.role_manager.id]
  }

  environment {
    variables = {
      DB_HOST                = aws_rds_cluster.db.endpoint
      DB_PORT                = aws_rds_cluster.db.port
      DB_USER                = local.master_username
      DB_NAME                = aws_rds_cluster.db.database_name
      DB_PASSWORD_PARAM_NAME = aws_ssm_parameter.random_db_password.name
      DB_SCHEMA              = var.schema_name
      APP_USER               = var.app_username
      MIGRATOR_USER          = var.migrator_username
      PYTHONPATH             = "vendor"
    }
  }

  # Ensure AWS Lambda functions with tracing are enabled
  # https://docs.bridgecrew.io/docs/bc_aws_serverless_4
  tracing_config {
    mode = "Active"
  }

  # checkov:skip=CKV_AWS_272:TODO(https://github.com/navapbc/template-infra/issues/283)

  # checkov:skip=CKV_AWS_116:Dead letter queue (DLQ) configuration is only relevant for asynchronous invocations
}

# Installs python packages needed by the role manager lambda function before
# creating the zip archive. Reinstalls whenever requirements.txt changes
resource "terraform_data" "role_manager_python_vendor_packages" {
  triggers_replace = file("${path.module}/role_manager/requirements.txt")

  provisioner "local-exec" {
    command = "pip3 install -r ${path.module}/role_manager/requirements.txt -t ${path.module}/role_manager/vendor"
  }
}

data "archive_file" "role_manager" {
  type        = "zip"
  source_dir  = "${path.module}/role_manager"
  output_path = local.role_manager_package
  depends_on  = [terraform_data.role_manager_python_vendor_packages]
}

# KMS key used to encrypt role manager's environment variables
resource "aws_kms_key" "role_manager" {
  description         = "Key for Lambda function ${local.role_manager_name}"
  enable_key_rotation = true
}



