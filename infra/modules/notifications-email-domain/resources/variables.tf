variable "domain_name" {
  description = "The domain name to configure SES, also used as the resource names"
  type        = string
}

variable "hosted_zone_id" {
  description = "The Route53 hosted zone id for the domain"
  type        = string
}
