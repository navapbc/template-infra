########################################
# Default Privileges for readonly role
########################################

# ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO readonly;
resource "postgresql_default_privileges" "def_privs_schema_public_select_tables_readonly" {
  depends_on  = [module.base_roles, postgresql_grant.revoke_public, postgresql_grant.revoke_db_public]
  role        = "readonly"
  database    = var.db_name
  schema      = "public"
  owner       = var.admin_user
  object_type = "table"
  privileges  = ["SELECT"]
}

# ALTER DEFAULT PRIVILEGES FOR ROLE readwrite IN SCHEMA public GRANT SELECT ON TABLES TO readonly;"
resource "postgresql_default_privileges" "def_privs_readwrite_schema_public_select_tables_readonly" {
  depends_on  = [module.base_roles, postgresql_grant.revoke_public, postgresql_grant.revoke_db_public]
  role        = "readonly"
  database    = var.db_name
  schema      = "public"
  owner       = "readwrite"
  object_type = "table"
  privileges  = ["SELECT"]
}

# ALTER DEFAULT PRIVILEGES FOR ROLE flyway_user IN SCHEMA public GRANT SELECT ON TABLES TO readonly;"
resource "postgresql_default_privileges" "def_privs_flyway_user_schema_public_select_tables_readonly" {
  depends_on  = [module.base_roles, postgresql_grant.revoke_public, postgresql_grant.revoke_db_public]
  role        = "readonly"
  database    = var.db_name
  schema      = "public"
  owner       = "flyway_user"
  object_type = "table"
  privileges  = ["SELECT"]
}

########################################
# Default Privileges for readwrite role
########################################

# ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO readwrite;
resource "postgresql_default_privileges" "def_privs_schema_public_sel_in_up_del_tables_readwrite" {
  depends_on  = [module.base_roles, postgresql_grant.revoke_public, postgresql_grant.revoke_db_public]
  role        = "readwrite"
  database    = var.db_name
  schema      = "public"
  owner       = var.admin_user
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
}

# ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE ON SEQUENCES TO readwrite;
resource "postgresql_default_privileges" "def_privs_schema_public_usage_seqs_readwrite" {
  depends_on  = [module.base_roles, postgresql_grant.revoke_public, postgresql_grant.revoke_db_public]
  role        = "readwrite"
  database    = var.db_name
  schema      = "public"
  owner       = var.admin_user
  object_type = "sequence"
  privileges  = ["USAGE"]
}

# ALTER DEFAULT PRIVILEGES FOR ROLE flyway_user IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO readwrite;
resource "postgresql_default_privileges" "def_privs_flyway_user_schema_public_sel_in_up_del_tables_readwrite" {
  depends_on  = [module.base_roles, postgresql_grant.revoke_public, postgresql_grant.revoke_db_public]
  role        = "readwrite"
  database    = var.db_name
  schema      = "public"
  owner       = "flyway_user"
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
}

# ALTER DEFAULT PRIVILEGES FOR ROLE flyway_user IN SCHEMA public GRANT USAGE ON SEQUENCES TO readwrite;
resource "postgresql_default_privileges" "def_privs_flyway_user_schema_public_usage_seqs_readwrite" {
  depends_on  = [module.base_roles, postgresql_grant.revoke_public, postgresql_grant.revoke_db_public]
  role        = "readwrite"
  database    = var.db_name
  schema      = "public"
  owner       = "flyway_user"
  object_type = "sequence"
  privileges  = ["USAGE"]
}

########################################
# Default Privileges for db_admin role
########################################

# ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO db_admin;
resource "postgresql_default_privileges" "def_privs_schema_public_sel_in_up_del_tables_db_admin" {
  depends_on  = [module.base_roles, postgresql_grant.revoke_public, postgresql_grant.revoke_db_public]
  role        = "db_admin"
  database    = var.db_name
  schema      = "public"
  owner       = var.admin_user
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
}

# ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE ON SEQUENCES TO db_admin;
resource "postgresql_default_privileges" "def_privs_schema_public_usage_seqs_db_admin" {
  depends_on  = [module.base_roles, postgresql_grant.revoke_public, postgresql_grant.revoke_db_public]
  role        = "db_admin"
  database    = var.db_name
  schema      = "public"
  owner       = var.admin_user
  object_type = "sequence"
  privileges  = ["USAGE"]
}
