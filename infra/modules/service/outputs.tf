output "load_balancer_endpoint" {
  description = "The load balancer endpoint for the service."
  value       = "http://${aws_lb.alb.dns_name}"
}

output "public_endpoint" {
  description = "The public endpoint for the service."
  value       = "https://${aws_route53_record.app.fqdn}"
}
