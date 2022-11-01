output "target_group_arn" {
  value = aws_lb_target_group.api_tg.arn
}

output "security_group_id" {
  value = aws_security_group.alb.id
}

output "dns_name" {
  value = aws_lb.alb.dns_name
}
