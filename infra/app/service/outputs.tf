output "load_balancer_endpoint" {
  description = "The load balancer endpoint for the service."
  value       = module.service.load_balancer_endpoint
}

output "service_endpoint" {
  description = "The public endpoint for the service."
  value       = module.service.public_endpoint
}
