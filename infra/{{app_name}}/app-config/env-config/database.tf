locals {
  database_config = var.has_database ? {
    region       = var.default_region
    cluster_name = "${var.app_name}-${var.environment}"

    # "standard" (free, 7-day window) or "advanced" (paid, 465-day retention).
    # See docs/infra/set-up-database.md#database-monitoring
    database_insights_mode = var.database_insights_mode

    # Enable extensions that require the rds_superuser role to be created here
    # See docs/infra/set-up-database.md for more information
    superuser_extensions = {}
  } : null
}
