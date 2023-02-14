resource "postgresql_role" "db_user" {
  name  = var.name
  login = var.login
  roles = var.roles
}

# only create a new secret if an existing secret is not specified
# this only creates the secret in secrets manager but does not set a value, which will be done out of band
resource "aws_secretsmanager_secret" "db_user_password" {
  depends_on = [postgresql_role.db_user]
  count      = var.login == true && !contains(var.roles, "rds_iam") && var.secret_name == "" ? 1 : 0
  name       = "${var.secret_namespace}/db_${var.name}_password"
  kms_key_id = var.secrets_manager_kms_key
}

resource "null_resource" "update_db_user_password" {

  depends_on = [aws_secretsmanager_secret.db_user_password]
  count      = var.login == true && !contains(var.roles, "rds_iam") && var.secret_name == "" ? 1 : 0
  provisioner "local-exec" {
    command = "${path.module}/update_user_password.sh"

    environment = {
      PGUSER                 = var.admin_user
      PGHOST                 = var.db_host
      PGDATABASE             = var.db_name
      PGPASSWORD             = var.pg_password
      USER                   = var.name
      SECRET_NAME            = var.secret_name != "" ? var.secret_name : "${var.secret_namespace}/db_${var.name}_password"
      UPDATE_SECRETS_MANAGER = var.secret_name != "" ? "" : "TRUE"
    }
  }
}

# this is a null_resource that does nothing
# it is defined to support importing of existing database users
# with passwords already set and stored in Secrets Manager
# such that the update_user_password script above is not run
#
# Steps to import an existing user that already a password and secret defined:
# - terraform apply -target=null_resource.import_do_nothing
# - terraform state mv null_resource.nothing null_resource.update_db_user_password
# - terraform apply (will propose adding null_resource.import_do_nothing, which is safe to apply)
#

resource "null_resource" "import_do_nothing" {

  depends_on = [aws_secretsmanager_secret.db_user_password]
  count      = var.login == true && !contains(var.roles, "rds_iam") && var.secret_name == "" ? 1 : 0
}
