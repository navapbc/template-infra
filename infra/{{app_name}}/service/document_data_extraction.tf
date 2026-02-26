
locals {
  document_data_extraction_config = local.environment_config.document_data_extraction_config

  expanded_blueprints = local.document_data_extraction_config != null ? flatten([
    for bp in local.document_data_extraction_config.blueprints :
    # if it's a glob pattern (contains *), expand it
    can(regex("\\*", bp)) ? [
      for file in fileset(path.module, bp) : "${path.module}/${file}"
    ] : [bp] # Otherwise use as-is (for ARNs or explicit paths)
  ]) : []

  document_data_extraction_environment_variables = local.document_data_extraction_config != null ? {
    DDE_INPUT_LOCATION  = "s3://${local.prefix}${local.document_data_extraction_config.input_bucket_name}"
    DDE_OUTPUT_LOCATION = "s3://${local.prefix}${local.document_data_extraction_config.output_bucket_name}"
    DDE_PROJECT_ARN     = module.dde[0].bda_project_arn
    DDE_PROFILE_ARN     = module.dde[0].bda_profile_arn
  } : {}
}

provider "aws" {
  alias  = "dde"
  region = local.document_data_extraction_config != null ? local.document_data_extraction_config.bda_region : local.service_config.region
}

provider "awscc" {
  alias  = "dde"
  region = local.document_data_extraction_config != null ? local.document_data_extraction_config.bda_region : local.service_config.region
}

module "dde_input_bucket" {
  providers = {
    aws = aws.dde
  }

  count                          = local.document_data_extraction_config != null ? 1 : 0
  source                         = "../../modules/storage"
  name                           = "${local.prefix}${local.document_data_extraction_config.input_bucket_name}"
  is_temporary                   = local.is_temporary
  service_principals_with_access = ["bedrock.amazonaws.com"]
}

module "dde_output_bucket" {
  providers = {
    aws = aws.dde
  }

  count                          = local.document_data_extraction_config != null ? 1 : 0
  source                         = "../../modules/storage"
  name                           = "${local.prefix}${local.document_data_extraction_config.output_bucket_name}"
  is_temporary                   = local.is_temporary
  service_principals_with_access = ["bedrock.amazonaws.com"]
}

module "dde" {
  providers = {
    aws   = aws.dde
    awscc = awscc.dde
  }

  count  = local.document_data_extraction_config != null ? 1 : 0
  source = "../../modules/document-data-extraction/resources"


  standard_output_configuration = local.document_data_extraction_config.standard_output_configuration
  blueprints                    = local.expanded_blueprints
  tags                          = local.tags

  name = "${local.prefix}${local.document_data_extraction_config.name}"
}
