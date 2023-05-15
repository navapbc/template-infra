output "load_balancer_security_group_id" {
  value = aws_security_group.public_load_balancer.id
}

output "service_security_group_id" {
  value = aws_security_group.private_service.id
}

output "database_security_group_id" {
  value = aws_security_group.private_database.id
}
