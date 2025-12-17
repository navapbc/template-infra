locals {
  # convert standard terraform tags to bedrock data automation format
  bda_tags = [
    for key, value in var.tags : {
      key   = key
      value = value
    }
  ]

  kms_encryption_context = {
    Environment = lookup(var.tags, "environment", "unknown")
  }
}

resource "awscc_bedrock_data_automation_project" "bda_project" {
  project_name                  = "${var.name}-project"
  project_description           = "Project for ${var.name}"
  kms_encryption_context        = local.kms_encryption_context
  kms_key_id                    = aws_kms_key.bedrock_data_automation.arn
  tags                          = local.bda_tags
  standard_output_configuration = var.standard_output_configuration
  custom_output_configuration = {
    blueprints = [for k, v in awscc_bedrock_blueprint.bda_blueprint : {
      blueprint_arn   = v.blueprint_arn
      blueprint_stage = v.blueprint_stage
    }]
  }
  override_configuration = var.override_configuration
}

resource "awscc_bedrock_blueprint" "bda_blueprint" {
  for_each = var.blueprints_map

  blueprint_name         = "${var.name}-${each.key}"
  schema                 = each.value.schema
  type                   = each.value.type
  kms_encryption_context = local.kms_encryption_context
  kms_key_id             = aws_kms_key.bedrock_data_automation.arn
  tags                   = local.bda_tags
}

resource "aws_iam_role" "bda_role" {
  name = "${var.name}-bda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "role_policy_attachments" {
  for_each = var.bucket_policy_arns

  role       = aws_iam_role.bda_role.name
  policy_arn = each.value
}