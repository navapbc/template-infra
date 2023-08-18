output "backup_role_arn" {
  value = aws_iam_role.db_backup_role.arn
}

output "role_manager_arn" {
  value = aws_iam_role.role_manager.arn
}

output "role_manager_monitoring_arn" {
  value = aws_iam_role.rds_enhanced_monitoring.arn
}
