output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "region" {
  value = data.aws_region.current.name
}

output "public_endpoint" {
  description = "The public endpoint for the service."
  value       = module.app.public_endpoint
}
