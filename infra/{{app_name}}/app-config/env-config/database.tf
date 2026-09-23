locals {
  database_config = var.has_database ? {
    region       = var.default_region
    cluster_name = "${var.app_name}-${var.environment}"

    # "standard" (free, 7-day window) or "advanced" (paid, 465-day retention).
    # See docs/infra/set-up-database.md#database-monitoring
    database_insights_mode = var.database_insights_mode

    # null keeps the cluster's existing retention. See
    # docs/infra/set-up-database.md#database-monitoring
    performance_insights_retention_period = var.performance_insights_retention_period

    # Enable extensions that require the rds_superuser role to be created here
    # See docs/infra/set-up-database.md for more information
    superuser_extensions = {}
  } : null
}
