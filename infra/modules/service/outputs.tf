output "public_endpoint" {
  description = "The public endpoint for the service."
  value       = "http://${aws_lb.alb.dns_name}"
}

output "cluster_name" {
  value = aws_ecs_cluster.cluster.name
}

output "load_balancer_name" {
  value = aws_lb.alb.name
}

