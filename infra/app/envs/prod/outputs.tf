output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "region" {
  value = data.aws_region.current.name
}

output "public_endpoint" {
  description = "The DNS name of the load balancer that is created in the service module."
  value       = module.app.public_endpoint
}
