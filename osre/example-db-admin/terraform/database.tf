locals {
  db_host = data.terraform_remote_state.mtde_rds_aurora.outputs.endpoint
  db_users = {
    app = {
      name  = "app"
      login = true
      roles = ["readwrite"]
    }
    flyway_user = {
      name  = "flyway_user"
      login = true
      roles = ["db_admin", "rds_iam"]
    }
    ado = {
      name  = "ado"
      login = true
      roles = ["readonly", "rds_iam"]
    }
  }
}

provider "postgresql" {
  scheme    = "awspostgres"
  host      = local.db_host
  username  = "mtde"
  port      = 5432
  password  = var.db_master_password
  superuser = false
}

module "postgres_mgt" {
  source = "../../../modules/tf-postgresql-admin/terraform"

  environment_name        = var.environment_name
  aws_region              = var.aws_region
  admin_user              = "example"
  db_host                 = local.db_host
  pg_password             = var.db_master_password
  db_name                 = "example"
  secret_namespace        = "/mpsm/${var.environment_name}/example-db"
  create_dmod_user        = false
  create_nessus_user      = true
  secrets_manager_kms_key = data.aws_kms_key.kms_key.arn

  db_users = merge(local.db_users, var.db_users)
}

data "aws_kms_key" "kms_key" {
  key_id = data.terraform_remote_state.common.outputs.secrets_manager_kms_key
}
