locals {
  document_data_extraction_config = var.enable_document_data_extraction ? {
    name               = "${var.app_name}-${var.environment}"
    input_bucket_name  = "${var.app_name}-${var.environment}-bda-input"
    output_bucket_name = "${var.app_name}-${var.environment}-bda-output"
    blueprints_path    = "./document-data-extraction-blueprints/"

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
