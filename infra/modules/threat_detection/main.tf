# GuardDuty centralized module
# This module manages the current account+region GuardDuty detector for malware protection

# Create and enable GuardDuty detector (single detector for current region)
resource "aws_guardduty_detector" "main" {
  # checkov:skip=CKV2_AWS_3:GuardDuty is enabled for this specific region/account - org-level management not required for single-account setup
  enable                       = var.enable_detector
  finding_publishing_frequency = var.finding_publishing_frequency
}

