locals {
  document_data_extraction_config = var.enable_document_data_extraction ? {
    name               = "${var.app_name}-${var.environment}"
    input_bucket_name  = "${local.bucket_name}-dde-input"
    output_bucket_name = "${local.bucket_name}-dde-output"

    # List of blueprint file paths or ARNs
    # File paths are relative to the service directory
    # ARNs reference AWS-managed or existing custom blueprints
    blueprints = [
      "./document-data-extraction-blueprints/*"
    ]

    # BDA can only be deployed to us-east-1, us-west-2, and us-gov-west-1
    # TODO(https://github.com/navapbc/template-infra/issues/993) Add GovCloud Support
    bda_region = "us-east-1"

    standard_output_configuration = {
      image = {
        extraction = {
          bounding_box = {
            state = "ENABLED"
          }
          category = {
            state = "ENABLED"
            types = ["TEXT_DETECTION", "LOGOS"]
          }
        }
        generative_field = {
          state = "ENABLED"
          types = ["IMAGE_SUMMARY"]
        }
      }
    }

  } : null
}
