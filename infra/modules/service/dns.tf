#
# DNS names using Amazon Route 53 and SSL certificates using ACM.
#

# Route 53 zone that will be used - assumed created elsewhere.
data "aws_route53_zone" "zone" {
  name = var.dns_zone
}

# DNS record that maps the public name to the load balancer.
resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.service_name

  type = "A"
  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

# ACM certificate that will be used by the load balancer.
resource "aws_acm_certificate" "app" {
  domain_name       = "${aws_route53_record.app.name}.${var.dns_zone}"
  validation_method = "DNS"
}

# DNS records for certificate validation.
resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.app.domain_validation_options
    : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  zone_id         = data.aws_route53_zone.zone.zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 60
  records         = [each.value.record]
}

# Representation of successful validation of the ACM certificate.
resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.app.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}
