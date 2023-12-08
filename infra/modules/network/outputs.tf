output "vpc_id" {
  description = "VPC ID"
  value       = module.aws_vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnets"
  value       = module.aws_vpc.public_subnets
}

output "private_subnet_ids" {
  description = "Public subnets"
  value       = module.aws_vpc.private_subnets
}

output "database_subnet_ids" {
  description = "Database subnets"
  value       = module.aws_vpc.database_subnets
}
