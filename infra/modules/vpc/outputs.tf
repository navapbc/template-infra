output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "Public Subnets"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "Public Subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets_cidr_blocks" {
  description = "Public Subnets CIDR Blocks"
  value       = module.vpc.public_subnets_cidr_blocks
}

output "private_subnets_cidr_blocks" {
  description = "Private Subnets CIDR Blocks"
  value       = module.vpc.public_subnets_cidr_blocks
}

output "nat_gateway_public_ips" {
  description = "NAT Gateway Public IP's"
  value       = module.vpc.nat_public_ips
}
