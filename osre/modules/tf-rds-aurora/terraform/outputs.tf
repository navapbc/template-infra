output "endpoint" {
  value       = aws_rds_cluster.rds_aurora_cluster.endpoint
  description = "The endpoint of the RDS instance"
}

output "endpoint_read_only" {
  value       = aws_rds_cluster.rds_aurora_cluster.reader_endpoint
  description = "The read-only endpoint of the RDS instance"
}

output "cluster_resource_id" {
  value       = aws_rds_cluster.rds_aurora_cluster.cluster_resource_id
  description = "The region-unique, immutable identifier for the RDS cluster."
}

output "cluster_resource_arn" {
  value       = aws_rds_cluster.rds_aurora_cluster.arn
  description = "The RDS cluster's ARN"
}