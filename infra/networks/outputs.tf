output "certificate_arns" {
  value = module.domain.certificate_arns
}

output "certificate_domains" {
  value = keys(local.domain_config.certificate_configs)
}

output "hosted_zone_name_servers" {
  value = module.domain.hosted_zone_name_servers
}
