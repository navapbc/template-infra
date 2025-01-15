resource "aws_route53_record" "dkim" {
  count = 3

  allow_overwrite = true
  ttl             = 60
  type            = "CNAME"
  zone_id         = var.hosted_zone_id
  name            = "${aws_sesv2_email_identity.sender_domain.dkim_signing_attributes[0].tokens[count.index]}._domainkey.${var.domain_name}"
  records         = ["${aws_sesv2_email_identity.sender_domain.dkim_signing_attributes[0].tokens[count.index]}.dkim.amazonses.com"]

  depends_on = [aws_sesv2_email_identity.sender_domain]
}

resource "aws_route53_record" "spf_mail_from" {
  allow_overwrite = true
  ttl             = "600"
  type            = "TXT"
  zone_id         = var.hosted_zone_id
  name            = aws_sesv2_email_identity_mail_from_attributes.sender_domain.mail_from_domain
  records         = ["v=spf1 include:amazonses.com ~all"]
}

resource "aws_route53_record" "mx_receive" {
  allow_overwrite = true
  type            = "MX"
  ttl             = "600"
  name            = local.mail_from_domain
  zone_id         = var.hosted_zone_id
  records         = ["10 feedback-smtp.${data.aws_region.current.name}.amazonaws.com"]
}
