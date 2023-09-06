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

output "application_log_group" {
  value = local.log_group_name
}

output "application_log_stream_prefix" {
  value = local.log_stream_prefix
}

output "migrator_role_arn" {
  description = "ARN for role to use for migration"
  value       = length(aws_iam_role.migrator_task) > 0 ? aws_iam_role.migrator_task[0].arn : null
}
