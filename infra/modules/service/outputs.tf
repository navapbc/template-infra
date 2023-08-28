output "public_endpoint" {
  description = "The public endpoint for the service."
  value       = "http://${aws_lb.alb.dns_name}"
}

output "cluster_name" {
  value = aws_ecs_cluster.cluster.name
}

output "load_balancer_arn_suffix" {
  description = "The ARN suffix for use with CloudWatch Metrics."
  value       = aws_lb.alb.arn_suffix
}

output "migrator_role_arn" {
  description = "ARN for role to use for migration"
  value       = aws_iam_role.migrator_service.arn
}
