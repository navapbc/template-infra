# Bedrock Data Automation Terraform Module

This module provisions AWS Bedrock Data Automation resources, including the data automation project, blueprints, and associated IAM role for accessing S3 buckets.

## Overview

The module creates:
- **Bedrock Data Automation Project** - Main project resource for data automation workflows
- **Bedrock Blueprints** - Custom extraction blueprints configured via a map
- **IAM Role** - Role for Bedrock service to assume with access to input/output S3 buckets

## Features
- Creates resources required for Bedrock Data Automation workflows
- Uses a `name_prefix` variable to prefix all resource names for uniqueness and consistency
- Supports both standard and custom output configurations
- Flexible blueprint creation through a map of blueprint definitions
- Complies with Checkov recommendations for security and compliance
- Designed for cross-layer usage (see project module conventions)

## Usage

```hcl
module "bedrock_data_automation" {
  source = "../../modules/document-data-extraction/resources/bedrock-data-automation"
  
  name_prefix = "my-app-prod"
  
  bucket_policy_arns = {
    input_bucket  = aws_iam_policy.input_bucket_policy.arn
    output_bucket = aws_iam_policy.output_bucket_policy.arn
  }
  
  blueprints_map = {
    invoice = {
      schema                 = file("${path.module}/schemas/invoice.json")
      type                   = "DOCUMENT"
      kms_encryption_context = {}
      kms_key_id             = aws_kms_key.bda_key.id
      tags = [
        {
          key   = "Environment"
          value = "production"
        }
      ]
    }
  }
  
  project_description = "Production data automation for invoice processing"
  
  standard_output_configuration = {
    document = {
      extraction = {
        granularity = {
          types = ["PAGE", "ELEMENT"]
        }
      }
    }
  }
  
  tags = [
    {
      key   = "Environment"
      value = "production"
    },
    {
      key   = "ManagedBy"
      value = "terraform"
    }
  ]
}
```

## Inputs

### Required Variables

| Name  | Description | Type | Required |
|-------|-------------|------|----------|
| `name_prefix` | Prefix to use for resource names (e.g., "my-app-prod") | `string` | yes |
| `bucket_policy_arns` | Map of policy ARNs for input and output buckets to attach to the BDA role | `map(string)` | yes |
| `blueprints_map` | Map of unique blueprints with keys as blueprint identifiers and values as blueprint objects | `map(object)` | yes |

#### `blueprints_map` Object Structure
```hcl
{
  schema                 = string              # JSON schema defining the extraction structure
  type                   = string              # Blueprint type (e.g., "DOCUMENT")
  kms_encryption_context = map(string)         # KMS encryption context
  kms_key_id             = string              # KMS key ID for encryption
  tags = list(object({                         # Resource tags
    key   = string
    value = string
  }))
}
```

### Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `bda_project_description` | The description of the Bedrock data automation project | `string` | `null` |
| `bda_kms_encryption_context` | The KMS encryption context for the Bedrock data automation project | `map(string)` | `null` |
| `bda_kms_key_id` | The KMS key ID for the Bedrock data automation project | `string` | `null` |
| `bda_custom_output_config` | List of BDA custom output configuration blueprint(s) | `list(object)` | `null` |
| `bda_override_config_state` | Configuration state for the BDA override | `string` | `null` |
| `bda_tags` | List of tag keys and values for the Bedrock data automation project | `list(object)` | `null` |

#### `bda_custom_output_config` Object Structure
```hcl
list(object({
  blueprint_arn     = optional(string)
  blueprint_stage   = optional(string)
  blueprint_version = optional(string)
}))
```

#### `standard_output_configuration` Object Structure

Complex nested object supporting extraction configuration for audio, document, image, and video content types. Each content type supports:
- **extraction** - Category, bounding box, and granularity configuration
- **generative_field** - State and types for generative AI fields
- **output_format** (document only) - Additional file format and text format settings

See `variables.tf` for complete structure details.

#### `bda_tags` Object Structure
```hcl
list(object({
  key   = string
  value = string
}))
```

## Outputs

| Name | Description |
|------|-------------|
| `bda_project_arn` | The ARN of the Bedrock Data Automation project |
| `bda_role_name` | The name of the IAM role used by Bedrock Data Automation |
| `bda_role_arn` | The ARN of the IAM role used by Bedrock Data Automation |

## Resources Created

- `awscc_bedrock_data_automation_project.bda_project` - Main BDA project
- `awscc_bedrock_blueprint.bda_blueprint` - One or more blueprints (created from `blueprints_map`)
- `aws_iam_role.bda_role` - IAM role for Bedrock service
- `aws_iam_role_policy_attachment.role_policy_attachments` - Policy attachments for S3 access

## Project Conventions

- All resource names are prefixed with `var.name_prefix`
- For cross-layer modules, use the interface/data/resources pattern as described in project documentation
- Write code that complies with Checkov recommendations
- Follow Terraform best practices for naming and organization

## File Structure

- `main.tf` - Resource definitions
- `variables.tf` - Input variable definitions
- `outputs.tf` - Output values
- `providers.tf` - Provider configuration
- `README.md` - This documentation

## Examples

### Minimal Configuration
```hcl
module "bedrock_data_automation" {
  source = "../../modules/document-data-extraction/resources/bedrock-data-automation"
  
  name_prefix = "my-app"
  
  bucket_policy_arns = {
    input  = aws_iam_policy.input.arn
    output = aws_iam_policy.output.arn
  }
  
  blueprints_map = {}  # No custom blueprints
}
```

### With Standard Output Configuration
```hcl
module "bedrock_data_automation" {
  source = "../../modules/document-data-extraction/resources/bedrock-data-automation"
  
  name_prefix        = "my-app"
  bucket_policy_arns = { /* ... */ }
  blueprints_map     = { /* ... */ }
  
  standard_output_configuration = {
    document = {
      extraction = {
        bounding_box = {
          state = "ENABLED"
        }
        granularity = {
          types = ["PAGE", "ELEMENT", "LINE"]
        }
      }
      generative_field = {
        state = "ENABLED"
      }
      output_format = {
        text_format = {
          types = ["MARKDOWN", "HTML"]
        }
      }
    }
    image = {
      extraction = {
        category = {
          state = "ENABLED"
          types = ["TABLES", "CHARTS"]
        }
      }
    }
  }
}
```

## Prerequisites

- AWS provider configured
- AWS Cloud Control provider (awscc) configured
- Appropriate AWS permissions to create Bedrock and IAM resources
- KMS keys (if using encryption)
- S3 bucket policies defined for input/output buckets

## References

- [AWS Bedrock Data Automation](https://docs.aws.amazon.com/bedrock/latest/userguide/data-automation.html)
- [Project Terraform Conventions](../../../../.github/copilot-instructions.md)
- [Checkov Documentation](https://www.checkov.io/)
