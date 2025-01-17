locals {
  domain_config = local.environment_config.domain_config

  hosted_zone_id  = local.domain_config.domain_name != null ? data.aws_route53_zone.zone[0].zone_id : null
  certificate_arn = local.domain_config.enable_https ? data.aws_acm_certificate.certificate[0].arn : null
}

data "aws_acm_certificate" "certificate" {
  count  = local.domain_config.enable_https ? 1 : 0
  domain = local.domain_config.domain_name
}

data "aws_route53_zone" "zone" {
  count = local.domain_config.domain_name != null ? 1 : 0
  name  = local.domain_config.hosted_zone
}
