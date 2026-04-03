locals {
  domain_config = local.environment_config.domain_config

  # For preview (temporary) environments, construct a domain name from the
  # workspace ID and service name so each preview gets a unique subdomain.
  # e.g. "pr-42.my-service.example.com"
  service_domain_name = local.is_temporary ? "${terraform.workspace}.${local.service_config.service_name}.${local.domain_config.hosted_zone}" : module.domain.domain_name
}

module "domain" {
  source = "../../modules/domain/data"

  hosted_zone  = local.domain_config.hosted_zone
  domain_name  = local.domain_config.domain_name
  enable_https = local.domain_config.enable_https
}
