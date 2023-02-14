locals {

  base_roles = {
    readonly = {
      name = "readonly"
    }
    readwrite = {
      name = "readwrite"
    }
    db_admin = {
      name = "db_admin"
    }
    rds_pgaudit = {
      name = "rds_pgaudit"
    }

  }

  dmod_user = var.create_dmod_user ? {
    dmod = {
      name  = "dmod"
      login = true
      roles = ["readwrite"]
    }
  } : {}

  nessus_user = var.create_nessus_user ? {
    nessusdb = {
      name        = "nessusdb"
      login       = true
      roles       = ["readonly"]
      secret_name = "/mpsm/devops/gdit/nessusdb_pg_password" # consider not hardcoding this value
    }
  } : {}

  db_roles = merge(local.dmod_user, local.nessus_user, var.db_users)
}

# set up base roles first
# to prevent users from being assigned base roles
# that have yet to be created
module "base_roles" {
  source   = "./roles"
  for_each = local.base_roles

  name                    = each.value.name
  admin_user              = var.admin_user
  db_host                 = var.db_host
  db_name                 = var.db_name
  pg_password             = var.pg_password
  secret_namespace        = var.secret_namespace
  secrets_manager_kms_key = var.secrets_manager_kms_key
}


module "roles" {
  depends_on = [
    module.base_roles
  ]
  source   = "./roles"
  for_each = local.db_roles

  name  = each.value.name
  login = lookup(each.value, "login", false)
  roles = lookup(each.value, "roles", [])

  admin_user              = var.admin_user
  db_host                 = var.db_host
  db_name                 = var.db_name
  pg_password             = var.pg_password
  secret_namespace        = var.secret_namespace
  secret_name             = lookup(each.value, "secret_name", "")
  secrets_manager_kms_key = var.secrets_manager_kms_key
}
