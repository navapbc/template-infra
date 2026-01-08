data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
locals {
  document_data_extraction_config = local.environment_config.document_data_extraction_config

  document_data_extraction_environment_variables = local.document_data_extraction_config != null ? {
    DDE_INPUT_BUCKET_NAME  = "${local.prefix}${local.document_data_extraction_config.input_bucket_name}"
    DDE_OUTPUT_BUCKET_NAME = "${local.prefix}${local.document_data_extraction_config.output_bucket_name}"
    DDE_PROJECT_ARN        = module.dde[0].bda_project_arn

    # aws bedrock data automation requires users to use cross Region inference support 
    # when processing files. the following like the profile ARNs for different inference
    # profiles
    # https://docs.aws.amazon.com/bedrock/latest/userguide/bda-cris.html
    DDE_PROFILE_ARN = "arn:aws:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:data-automation-profile/us.data-automation-v1"
  } : {}
}

module "dde_input_bucket" {
  count        = local.document_data_extraction_config != null ? 1 : 0
  source       = "../../modules/storage"
  name         = "${local.prefix}${local.document_data_extraction_config.input_bucket_name}"
  is_temporary = local.is_temporary
}

module "dde_output_bucket" {
  count        = local.document_data_extraction_config != null ? 1 : 0
  source       = "../../modules/storage"
  name         = "${local.prefix}${local.document_data_extraction_config.output_bucket_name}"
  is_temporary = local.is_temporary
}

module "dde" {
  count  = local.document_data_extraction_config != null ? 1 : 0
  source = "../../modules/document-data-extraction/resources"

  standard_output_configuration = local.document_data_extraction_config.standard_output_configuration
  tags                          = local.tags

  blueprints_map = {
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
