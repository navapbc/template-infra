
locals {
  document_data_extraction_config = local.environment_config.document_data_extraction_config

  document_data_extraction_environment_variables = local.document_data_extraction_config != null ? {
    DDE_INPUT_LOCATION  = "${local.prefix}${local.document_data_extraction_config.input_bucket_name}"
    DDE_OUTPUT_LOCATION = "${local.prefix}${local.document_data_extraction_config.output_bucket_name}"
    DDE_PROJECT_ARN     = module.dde[0].bda_project_arn
    DDE_PROFILE_ARN     = module.dde[0].bda_profile_arn
  } : {}
}

provider "aws" {
  alias  = "dde"
  region = local.document_data_extraction_config.bda_region
}

provider "awscc" {
  alias  = "dde"
  region = local.document_data_extraction_config.bda_region
}

module "dde_input_bucket" {
  providers = {
    aws = aws.dde
  }

  count        = local.document_data_extraction_config != null ? 1 : 0
  source       = "../../modules/storage"
  name         = "${local.prefix}${local.document_data_extraction_config.input_bucket_name}"
  is_temporary = local.is_temporary
}

module "dde_output_bucket" {
  providers = {
    aws = aws.dde
  }

  count        = local.document_data_extraction_config != null ? 1 : 0
  source       = "../../modules/storage"
  name         = "${local.prefix}${local.document_data_extraction_config.output_bucket_name}"
  is_temporary = local.is_temporary
}

module "dde" {
  providers = {
    aws   = aws.dde
    awscc = awscc.dde
  }

  count  = local.document_data_extraction_config != null ? 1 : 0
  source = "../../modules/document-data-extraction/resources"

  standard_output_configuration = local.document_data_extraction_config.standard_output_configuration
  tags                          = local.tags

  blueprints_map = {
    # JPG/PNG can be processed as DOCUMENT or IMAGE types, but IMAGE types can only 
    # have a single custom blueprint so generally the blueprints will be for the DOCUMENT type
    for blueprint in fileset(local.document_data_extraction_config.blueprints_path, "*") :
    split(".", blueprint)[0] => {
      schema = file("${local.document_data_extraction_config.blueprints_path}/${blueprint}")
      type   = "DOCUMENT"
      tags   = local.tags
    }
  }

  name = "${local.prefix}${local.document_data_extraction_config.name}"

  data_access_policy_arns = {
    input_bucket  = module.dde_input_bucket[0].access_policy_arn,
    output_bucket = module.dde_output_bucket[0].access_policy_arn
  }
}
