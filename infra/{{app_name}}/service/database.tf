locals {
  database_config = local.environment_config.database_config
}

data "aws_rds_cluster" "db_cluster" {
  count              = module.app_config.has_database ? 1 : 0
  cluster_identifier = local.database_config.cluster_name
}

data "aws_iam_policy" "app_db_access_policy" {
  count = module.app_config.has_database ? 1 : 0
  name  = local.database_config.app_access_policy_name
}

data "aws_iam_policy" "migrator_db_access_policy" {
  count = module.app_config.has_database ? 1 : 0
  name  = local.database_config.migrator_access_policy_name
}

