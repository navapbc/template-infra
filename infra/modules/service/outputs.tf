output "public_endpoint" {
  description = "The DNS name of the load balancer that is created in the service module."
  value       = "http://${aws_lb.alb.dns_name}"
}
