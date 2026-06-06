locals {
  domain_name = var.domain_name
}

resource "aws_route53_record" "app" {
  count = local.domain_name != null && var.hosted_zone_id != null ? 1 : 0

  name    = local.domain_name
  zone_id = var.hosted_zone_id
  type    = "A"
  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}
