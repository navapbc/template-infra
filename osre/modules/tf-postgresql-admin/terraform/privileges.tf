# REVOKE CREATE ON SCHEMA public FROM PUBLIC;
resource "postgresql_grant" "revoke_public" {
  database    = var.db_name
  role        = "public"
  schema      = "public"
  object_type = "schema"
  privileges = [
    "USAGE"
  ]
}

# REVOKE ALL ON DATABASE "db" FROM PUBLIC;
resource "postgresql_grant" "revoke_db_public" {
  database    = var.db_name
  role        = "public"
  schema      = "public"
  object_type = "database"
  privileges  = []
}

##################################
# Privileges for readonly role
##################################


# GRANT CONNECT ON DATABASE "db" TO readonly;
resource "postgresql_grant" "grant_connect_db_readonly" {
  depends_on  = [module.base_roles, postgresql_grant.revoke_public, postgresql_grant.revoke_db_public]
  database    = var.db_name
  role        = "readonly"
  schema      = "public"
  object_type = "database"
  privileges = [
    "CONNECT"
  ]
}

# GRANT USAGE ON SCHEMA public TO readonly;
resource "postgresql_grant" "grant_usage_schema_public_readonly" {
  depends_on  = [module.base_roles, postgresql_grant.revoke_public, postgresql_grant.revoke_db_public]
  database    = var.db_name
  role        = "readonly"
  schema      = "public"
  object_type = "schema"
  privileges = [
    "USAGE"
  ]
}

# GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly;
resource "postgresql_grant" "grant_select_all_tables_schema_public_readonly" {
  depends_on  = [module.base_roles, postgresql_grant.revoke_public, postgresql_grant.revoke_db_public]
  database    = var.db_name
  role        = "readonly"
  schema      = "public"
  object_type = "table"
  objects     = []
  privileges = [
    "SELECT"
  ]
}

##################################
# Privileges for readwrite role
##################################

# GRANT CONNECT ON DATABASE "db" TO readwrite;
resource "postgresql_grant" "grant_connect_db_readwrite" {
  depends_on  = [module.base_roles, postgresql_grant.revoke_public, postgresql_grant.revoke_db_public]
  database    = var.db_name
  role        = "readwrite"
  schema      = "public"
  object_type = "database"
  privileges = [
    "CONNECT"
  ]
}

# GRANT USAGE, CREATE ON SCHEMA public TO readwrite;
resource "postgresql_grant" "grant_usage_create_schema_public_readwrite" {
  depends_on  = [module.base_roles, postgresql_grant.revoke_public, postgresql_grant.revoke_db_public]
  database    = var.db_name
  role        = "readwrite"
  schema      = "public"
  object_type = "schema"
  privileges = [
    "USAGE",
    "CREATE"
  ]
}

# GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO readwrite;
resource "postgresql_grant" "grant_sel_ins_up_del_tables_schema_public_readwrite" {
  depends_on  = [module.base_roles, postgresql_grant.revoke_public, postgresql_grant.revoke_db_public]
  database    = var.db_name
  role        = "readwrite"
  schema      = "public"
  object_type = "table"
  objects     = []
  privileges = [
    "SELECT",
    "INSERT",
    "UPDATE",
    "DELETE"
  ]
}

# GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO readwrite;
resource "postgresql_grant" "grant_usage_all_seqs_schema_public_readwrite" {
  depends_on  = [module.base_roles, postgresql_grant.revoke_public, postgresql_grant.revoke_db_public]
  database    = var.db_name
  role        = "readwrite"
  schema      = "public"
  object_type = "sequence"
  objects     = []
  privileges = [
    "USAGE",
  ]
}


##################################
# Privileges for db_admin role
##################################


# GRANT CREATE, CONNECT ON DATABASE "db" TO db_admin;
resource "postgresql_grant" "grant_connect_db_db_admin" {
  depends_on  = [module.base_roles, postgresql_grant.revoke_public, postgresql_grant.revoke_db_public]
  database    = var.db_name
  role        = "db_admin"
  schema      = "public"
  object_type = "database"
  privileges = [
    "CREATE",
    "CONNECT"
  ]
}

# GRANT USAGE, CREATE ON SCHEMA public TO db_admin;
resource "postgresql_grant" "grant_usage_create_schema_public_db_admin" {
  depends_on  = [module.base_roles, postgresql_grant.revoke_public, postgresql_grant.revoke_db_public]
  database    = var.db_name
  role        = "db_admin"
  schema      = "public"
  object_type = "schema"
  privileges = [
    "USAGE",
    "CREATE"
  ]
}

# GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO db_admin;
resource "postgresql_grant" "grant_sel_ins_up_del_tables_schema_public_db_admin" {
  depends_on  = [module.base_roles, postgresql_grant.revoke_public, postgresql_grant.revoke_db_public]
  database    = var.db_name
  role        = "db_admin"
  schema      = "public"
  object_type = "table"
  objects     = []
  privileges = [
    "SELECT",
    "INSERT",
    "UPDATE",
    "DELETE"
  ]
}

# GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO db_admin;
resource "postgresql_grant" "grant_usage_all_seqs_schema_public_db_admin" {
  depends_on  = [module.base_roles, postgresql_grant.revoke_public, postgresql_grant.revoke_db_public]
  database    = var.db_name
  role        = "db_admin"
  schema      = "public"
  object_type = "sequence"
  objects     = []
  privileges = [
    "USAGE",
  ]
}
