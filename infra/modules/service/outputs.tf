output "public_endpoint" {
  description = "The public endpoint for the service."
  value       = "http://${aws_lb.alb.dns_name}"
}
