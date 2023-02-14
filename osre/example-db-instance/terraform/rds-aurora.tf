locals {
  data_subnet_ids = module.gdit_vpc_data.data_subnet_ids
}

module "rds_aurora" {
  source = "../../../modules/tf-rds-aurora/terraform"

  vpc_name   = var.vpc_name
  vpc_id     = module.gdit_vpc_data.vpc_id
  subnet_ids = local.data_subnet_ids

  ingress_cidrs      = var.ingress_cidrs

  instance_count                      = var.instance_count
  environment_name                    = var.environment_name
  cloudwatch_notification_arn         = data.terraform_remote_state.common.outputs.osre_sns_topic
  database_name                       = "example"
  master_username                     = "example"
  engine                              = "aurora-postgresql"
  engine_version                      = var.db_engine_version
  db_port                             = 5432
  snapshot_identifier                 = var.snapshot_identifier
  update_password                     = var.update_password
  iam_database_authentication_enabled = true
  parameter_group_name_override       = "example-aurora-pg-${var.db_engine_major_version}-${var.environment_name}"
  enable_pg_cron                      = var.enable_pg_cron
  performance_insights_enabled        = var.performance_insights_enabled

  serverlessv2_scaling_configuration = {
    max_capacity = 8.0
    min_capacity = 0.5
  }

  backup_retention_period = 30

  application_name = "example"
}
