resource "aws_kms_key" "bedrock_data_automation" {
  description             = "KMS key for Bedrock Data Automation ${var.name}"
  deletion_window_in_days = "10"
  enable_key_rotation     = "true"
}

resource "aws_kms_alias" "bedrock_data_automation" {
  name          = "alias/${var.name}-bedrock-data-automation"
  target_key_id = aws_kms_key.bedrock_data_automation.key_id
}