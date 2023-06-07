output "database_host" {
  value       = module.database.database_host
  description = "The hostname of the database. Use this to connect to the database."
}

output "database_port" {
  value       = module.database.database_port
  description = "Value of the port on which the database accepts connections. Defaults to 5432."
}

output "database_name" {
  value       = module.database.database_name
  description = "The name of the PostgreSQL database. Not to be confused with the name/identifier of the database cluster in RDS."
}

output "cluster_security_group_id" {
  value       = module.database.cluster_security_group_id
  description = "The ID of the security group for the database cluster. Add ingress rules to allow network access to the database."
}

output "app_username" {
  value       = module.database.app_username
  description = "The username of the database user that the application uses to connect to the database."
}

output "migrator_username" {
  value       = module.database.migrator_username
  description = "The username of the database user that the migrator task uses to connect to the database to run migrations."
}

output "schema_name" {
  value       = module.database.schema_name
  description = "The name of the database schema that the application uses."
}

output "access_policy_arn" {
  value       = module.database.access_policy_arn
  description = "The ARN of the IAM policy that allows access to the database. Attach to an IAM role to grant access to the database."
}

output "role_manager_function_name" {
  value       = module.database.role_manager_function_name
  description = "The name of the Lambda function that manages PostgreSQL database roles. Invoke this function to create or update database roles."
}
