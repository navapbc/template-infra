/**
* tf-rds-aurora
*
* Creates an RDS Aurora Cluster with instances.
*
* Note: a random master password is set then ignored by terraform, the expectation
* is that you set that password out-of-band. This was done to avoid the password
* being tracked in terraform state.
*
*
*/

locals {
  cluster_identifier = "${var.environment_name}-${var.application_name}" 
  ingress_cidrs = var.ingress_cidrs
}

resource "random_string" "temporary_password" {
  length  = 20
  special = false # to prevent invalid characters from being generated
}

resource "aws_rds_cluster" "rds_aurora_cluster" {
  cluster_identifier = local.cluster_identifier
  engine             = var.engine
  engine_mode        = "provisioned" # serverless V2 requires the same engine mode
  engine_version     = var.engine_version
  db_subnet_group_name                = aws_db_subnet_group.rds_subnet_group.name
  database_name                       = var.database_name
  master_username                     = var.master_username
  master_password                     = random_string.temporary_password.result
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  port                                = var.db_port
  db_cluster_parameter_group_name     = aws_rds_cluster_parameter_group.cluster.id
  final_snapshot_identifier           = "${local.cluster_identifier}-${replace(var.engine_version, ".", "")}-final"
  backup_retention_period             = var.backup_retention_period
  storage_encrypted               = true
  deletion_protection             = true
  vpc_security_group_ids          = [aws_security_group.rds_security_group.id]
  skip_final_snapshot             = true

  snapshot_identifier = var.snapshot_identifier

  serverlessv2_scaling_configuration {
      max_capacity = var.serverlessv2_scaling_configuration.max_capacity
      min_capacity = var.serverlessv2_scaling_configuration.min_capacity
  }

  dynamic "restore_to_point_in_time" {
    for_each = var.restore_to_point_in_time == null ? toset([]) : toset([1])

    content {
      source_cluster_identifier  = var.restore_to_point_in_time.source_cluster_identifier
      restore_type               = var.restore_to_point_in_time.use_latest_restorable_time ? "copy-on-write" : "full-copy"
      restore_to_time            = var.restore_to_point_in_time.restore_to_time
      use_latest_restorable_time = var.restore_to_point_in_time.use_latest_restorable_time ? true : null
    }
  }

  tags = {
    application = var.application_name
    env         = var.environment_name
  }

  lifecycle {
    ignore_changes = [master_password, restore_to_point_in_time]
  }
}

# Have to define engine and engine_version in the cluster instance resource too
# Else the instance will default to a mismatched version
# https://github.com/terraform-providers/terraform-provider-aws/issues/4779
resource "aws_rds_cluster_instance" "cluster_instances" {
  count                                 = var.instance_count
  identifier                            = "${local.cluster_identifier}-instance-${count.index}"
  cluster_identifier                    = aws_rds_cluster.rds_aurora_cluster.id
  instance_class                        = "db.serverless"
  engine                                = var.engine
  engine_version                        = var.engine_version
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${local.cluster_identifier}-rds"
  subnet_ids = var.subnet_ids

  tags = {
    application = var.application_name
    env         = var.environment_name
  }
}

data "aws_region" "current" {}
module "cms_network_metadata" {
  source = "../../cms_network_metadata"
}

resource "aws_security_group" "rds_security_group" {
  description = "RDS"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = var.security_group_ids
    content {
      description     = ""
      from_port       = var.db_port
      to_port         = var.db_port
      protocol        = "tcp"
      security_groups = [ingress.value]
      self            = true
    }
  }

  ingress {
    description = ""
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = local.ingress_cidrs
  }

  name_prefix = "${local.cluster_identifier}-"

  tags = {
    application = var.application_name
    env         = var.environment_name
  }

  vpc_id = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

# sets up the secret
resource "aws_secretsmanager_secret" "db_password" {
  name = "/${var.environment_name}/${var.application_name}/db_master_password"
}

resource "null_resource" "update_rds_password" {

  count      = var.update_password ? 1 : 0
  depends_on = [aws_rds_cluster.rds_aurora_cluster, aws_rds_cluster_instance.cluster_instances, aws_secretsmanager_secret.db_password]
  # update master password
  provisioner "local-exec" {
    command = "${path.module}/../update_master_password.sh ${aws_rds_cluster.rds_aurora_cluster.id} /${var.environment_name}/${var.application_name}/db_master_password"
  }
}
