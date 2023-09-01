output "cluster_id" {
  value = aws_rds_cluster.db.id
}

output "role_manager_function_name" {
  value = aws_lambda_function.role_manager.function_name
}
