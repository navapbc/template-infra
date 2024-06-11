output "role_manager_function_name" {
  value = module.database.role_manager_function_name
}

output "enable_pgvector_extension" {
  value = local.database_config.enable_pgvector_extension
}