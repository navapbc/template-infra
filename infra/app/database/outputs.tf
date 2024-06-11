output "role_manager_function_name" {
  value = module.database.role_manager_function_name
}

output "superuser_extensions" {
  value = local.database_config.superuser_extensions
}