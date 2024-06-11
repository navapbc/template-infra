output "role_manager_function_name" {
  value = module.database.role_manager_function_name
}

output "db_config" {
  value = {
    "superuser_extensions" = local.database_config.superuser_extensions
  }
}