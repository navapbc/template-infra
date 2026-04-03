# Outputs for GuardDuty module

output "detector_id" {
  description = "GuardDuty detector ID"
  value       = aws_guardduty_detector.main.id
}

output "detector_arn" {
  description = "GuardDuty detector ARN"
  value       = aws_guardduty_detector.main.arn
}

# TODO: When upgrading to AWS provider >= 5.7.0, uncomment for multi-region support:
# Ticket: https://github.com/navapbc/template-infra/issues/1004#issue-4083076747
# output "detector_id" {
#   description = "GuardDuty detector IDs by region"
#   value       = { for k, v in aws_guardduty_detector.main : k => v.id }
# }
#
# output "detector_arn" {
#   description = "GuardDuty detector ARNs by region"
#   value       = { for k, v in aws_guardduty_detector.main : k => v.arn }
# }
