data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  master_username       = "postgres"
  primary_instance_name = "${var.name}-primary"
  role_manager_name     = "${var.name}-role-manager"
  # The ARN that represents the users accessing the database are of the format: "arn:aws:rds-db:<region>:<account-id>:dbuser:<resource-id>/<database-user-name>""
  # See https://aws.amazon.com/blogs/database/using-iam-authentication-to-connect-with-pgadmin-amazon-aurora-postgresql-or-amazon-rds-for-postgresql/
  db_user_arn_prefix = "arn:aws:rds-db:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_rds_cluster.db.cluster_resource_id}"

  engine_version       = "16"
  engine_major_version = regex("^\\d+", local.engine_version)

  # Advanced mode requires exactly 465 days of retention; standard mode only
  # supports the free 7-day window. Deriving this from the mode keeps the two
  # from drifting into an invalid combination.
  # https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/USER_DatabaseInsights.html
  performance_insights_retention_period = var.database_insights_mode == "advanced" ? 465 : 7
}

module "interface" {
  source = "../interface"
  name   = var.name
}

# Database Configuration
# ----------------------

resource "aws_rds_cluster" "db" {
  # checkov:skip=CKV2_AWS_27:have concerns about sensitive data in logs; want better way to get this information
  # checkov:skip=CKV2_AWS_8:TODO add backup selection plan using tags

  # cluster identifier is a unique identifier within the AWS account
  # https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.CreateInstance.html
  cluster_identifier = var.name

  engine                      = "aurora-postgresql"
  engine_mode                 = "provisioned"
  engine_version              = local.engine_version
  database_name               = var.database_name
  port                        = var.port
  master_username             = local.master_username
  manage_master_user_password = true
  storage_encrypted           = true
  kms_key_id                  = aws_kms_key.db.arn
  allow_major_version_upgrade = false

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.rds_query_logging.name

  # checkov:skip=CKV_AWS_128:Auth decision needs to be ironed out
  # checkov:skip=CKV_AWS_162:Auth decision needs to be ironed out
  iam_database_authentication_enabled = true
  copy_tags_to_snapshot               = true
  # final_snapshot_identifier = "${var.name}-final"
  skip_final_snapshot = true

  # Use a separate line to support automated terraform destroy commands
  # checkov:skip=CKV_AWS_139:Allow disabling deletion protection for automated tests
  deletion_protection = !var.is_temporary

  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }

  db_subnet_group_name   = module.network.database_subnet_group_name
  vpc_security_group_ids = [aws_security_group.db.id]

  enabled_cloudwatch_logs_exports = ["postgresql"]

  # AWS is retiring Performance Insights on 2026-07-31, replaced by Database
  # Insights. Setting these at the cluster level does NOT propagate to existing
  # instances, so aws_rds_cluster_instance sets them too -- see the comment there.
  database_insights_mode                = var.database_insights_mode
  performance_insights_enabled          = true
  performance_insights_retention_period = local.performance_insights_retention_period
  performance_insights_kms_key_id       = aws_kms_key.db.arn

  # Many DB modifications are by default queued up for the next maintenance
  # window, but when you want changes to happen now, set this.
  #
  # apply_immediately = true
}

resource "aws_rds_cluster_instance" "primary" {
  identifier                 = local.primary_instance_name
  cluster_identifier         = aws_rds_cluster.db.id
  instance_class             = "db.serverless"
  engine                     = aws_rds_cluster.db.engine
  engine_version             = aws_rds_cluster.db.engine_version
  auto_minor_version_upgrade = true
  monitoring_role_arn        = aws_iam_role.rds_enhanced_monitoring.arn
  monitoring_interval        = 30

  # Performance Insights is configured per instance as well as on the cluster.
  # The cluster-level setting applies to instances created afterwards; it does
  # not retroactively update instances that already exist, so both are set.
  # database_insights_mode is cluster-only and is not repeated here.
  performance_insights_enabled          = true
  performance_insights_retention_period = local.performance_insights_retention_period
  performance_insights_kms_key_id       = aws_kms_key.db.arn

  # Many DB modifications are by default queued up for the next maintenance
  # window, but when you want changes to happen now, set this.
  #
  # apply_immediately = true

}

resource "aws_kms_key" "db" {
  description         = "Key for RDS cluster ${var.name}"
  enable_key_rotation = true

  # checkov:skip=CKV2_AWS_64:The default key policy is acceptable
}

# Query Logging
# -------------

resource "aws_rds_cluster_parameter_group" "rds_query_logging" {
  name        = "${var.name}-${local.engine_major_version}"
  family      = "aurora-postgresql${local.engine_major_version}"
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

  lifecycle {
    # To support major version updates.
    create_before_destroy = true
  }
}
