resource "awscc_bedrock_data_automation_project" "bda_project" {
  project_name                  = "${var.name}-project"
  project_description           = var.project_description
  kms_encryption_context        = var.kms_encryption_context
  kms_key_id                    = var.kms_key_id
  tags                          = var.tags
  standard_output_configuration = var.standard_output_configuration
  custom_output_configuration = {
    blueprints = [for k, v in awscc_bedrock_blueprint.bda_blueprint : {
      blueprint_arn   = v.blueprint_arn
      blueprint_stage = v.blueprint_stage
    }]
  }
  override_configuration = {
    document = {
      splitter = {
        state = var.override_config_state
      }
    }
  }
}
resource "awscc_bedrock_blueprint" "bda_blueprint" {
  for_each = var.blueprints_map

  blueprint_name         = "${var.name}-${each.key}"
  schema                 = each.value.schema
  type                   = each.value.type
  kms_encryption_context = each.value.kms_encryption_context
  kms_key_id             = each.value.kms_key_id
  tags                   = each.value.tags
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