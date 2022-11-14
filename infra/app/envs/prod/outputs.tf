output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "region" {
  value = data.aws_region.current.name
}

output "dns_name" {
  description = "The DNS name of the load balancer."
  value       = data.aws_lb.current.dns_name
}

output "public_endpoint" {
  description = "The DNS name of the load balancer that is created in the service module."
  value       = data.aws_lb.alb.dns_name
}
