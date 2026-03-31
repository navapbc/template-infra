# GuardDuty centralized module
# This module manages the account-wide GuardDuty detector for malware protection

# Create and enable GuardDuty detector (single detector for current region)
resource "aws_guardduty_detector" "main" {
  # checkov:skip=CKV2_AWS_3:GuardDuty is enabled for this specific region/account - org-level management not required for single-account setup
  enable                       = var.enable_detector
  finding_publishing_frequency = var.finding_publishing_frequency
}

# TODO: When upgrading to AWS provider >= 5.7.0, uncomment the following for multi-region support: templaat-infra issue #1004
# Ticket: https://github.com/navapbc/template-infra/issues/1004#issue-4083076747
# resource "aws_guardduty_detector" "main" {
#   for_each = toset(var.regions)
#   # checkov:skip=CKV2_AWS_3:GuardDuty is enabled for this specific region/account - org-level management not required for single-account setup
#   enable                       = var.enable_detector
#   region                       = each.value
#   finding_publishing_frequency = var.finding_publishing_frequency
# }