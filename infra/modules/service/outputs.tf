output "public_endpoint" {
  value = "http://${aws_lb.alb.dns_name}"
}
