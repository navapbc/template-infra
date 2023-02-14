output "endpoint" {
  value       = element(split(":", module.rds_aurora.endpoint), 0)
  description = "The endpoint of the MTDE RDS Aurora instance"
}
