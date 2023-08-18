output "role_manager_sg_ids" {
  value = aws_security_group.role_manager.id
}

output "database_sg_ids" {
  value = aws_security_group.db.id
}
