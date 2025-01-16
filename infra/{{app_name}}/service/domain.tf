locals {
  domain_name    = local.service_config.domain_name
  hosted_zone_id = local.domain_name != null ? data.aws_route53_zone.zone[0].zone_id : null
}

data "aws_acm_certificate" "certificate" {
  count  = local.service_config.enable_https ? 1 : 0
  domain = local.domain_name
}

data "aws_route53_zone" "zone" {
  count = local.domain_name != null ? 1 : 0
  name  = local.network_config.domain_config.hosted_zone
}
