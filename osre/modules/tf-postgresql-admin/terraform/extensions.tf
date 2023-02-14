resource "postgresql_extension" "pgaudit" {
  name     = "pgaudit"
  database = var.db_name
}

resource "postgresql_extension" "pg_stat_statements" {
  name     = "pg_stat_statements"
  database = var.db_name
}
