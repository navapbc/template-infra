output "database_config" {
  value = var.has_database ? {
    cluster_name       = "${var.app_name}-${var.environment}"
    access_policy_name = "${var.app_name}-${var.environment}-db-access"
    app_username       = "app"
    migrator_username  = "migrator"
    schema_name        = var.app_name
  } : null
}

output "secret_name" {
  value = var.external_integration ? {
    aws_ssm_name = "Incident-management-integration-url-${var.app_name}-${var.environment}"
  } : null
}
