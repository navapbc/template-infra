output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "public_subnets" {
  description = "Public Subnets"
  value       = module.network.public_subnets
}

output "private_subnets" {
  description = "Public Subnets"
  value       = module.network.private_subnets
}

output "public_subnets_cidr_blocks" {
  description = "Public Subnets CIDR Blocks"
  value       = module.network.public_subnets_cidr_blocks
}

output "private_subnets_cidr_blocks" {
  description = "Private Subnets CIDR Blocks"
  value       = module.network.public_subnets_cidr_blocks
}

output "nat_public_ips" {
  description = "NAT Gateway Public IP's"
  value       = module.network.nat_public_ips
}
