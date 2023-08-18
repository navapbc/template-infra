data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
module "database-iam" {
  source             = "../database-iam"
  name               = var.name
  access_policy_name = var.access_policy_name
  app_username       = var.app_username
  migrator_username  = var.migrator_username
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

data "aws_rds_cluster" "db" {
  cluster_identifier = var.name
}

# Backup selection defines which resources to backup
# See https://docs.aws.amazon.com/aws-backup/latest/devguide/assigning-resources.html
# and https://docs.aws.amazon.com/aws-backup/latest/devguide/API_BackupSelection.html
resource "aws_backup_selection" "db_backup" {
  name         = "${var.name}-db-backup"
  plan_id      = aws_backup_plan.backup_plan.id
  iam_role_arn = module.database-iam.backup_role_arn

  resources = [
    data.aws_rds_cluster.db.arn
  ]
}

# Query Logging
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
