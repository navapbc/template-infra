output "database_host" {
  value       = aws_rds_cluster.db.endpoint
  description = "The hostname of the database. Use this to connect to the database."
}

output "database_port" {
  value       = aws_rds_cluster.db.port
  description = "Value of the port on which the database accepts connections. Defaults to 5432."
}

output "database_name" {
  value       = aws_rds_cluster.db.database_name
  description = "The name of the PostgreSQL database. Not to be confused with the name/identifier of the database cluster in RDS."
}

output "cluster_security_group_id" {
  value       = aws_security_group.db.id
  description = "The ID of the security group for the database cluster. Add ingress rules to allow network access to the database."
}

output "app_username" {
  value       = local.app_username
  description = "The username of the database user that the application uses to connect to the database."
}

output "migrator_username" {
  value       = local.migrator_username
  description = "The username of the database user that the migrator task uses to connect to the database to run migrations."
}

output "schema_name" {
  value       = local.schema_name
  description = "The name of the database schema that the application uses."
}

output "access_policy_arn" {
  value       = aws_iam_policy.db_access.arn
  description = "The ARN of the IAM policy that allows access to the database. Attach to an IAM role to grant access to the database."
}

output "role_manager_function_name" {
  value       = aws_lambda_function.role_manager.function_name
  description = "The name of the Lambda function that manages PostgreSQL database roles. Invoke this function to create or update database roles."
}
