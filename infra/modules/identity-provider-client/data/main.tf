############################################################################################
## A module for retrieving an existing Cognito User Pool and App Client
############################################################################################
module "identity_provider_client_interface" {
  source = "../interface"
  name   = var.name
}

data "aws_cognito_user_pools" "existing_user_pools" {
  name = var.name
}

data "aws_cognito_user_pool_clients" "existing_user_pool_clients" {
  user_pool_id = tolist(data.aws_cognito_user_pools.existing_user_pools.ids)[0]
}

data "aws_ssm_parameter" "existing_user_pool_client_secret" {
  name = module.identity_provider_client_interface.client_secret_ssm_name
}

data "aws_iam_policy" "existing_identity_access_policy" {
  name = module.identity_provider_client_interface.user_pool_access_policy_name
}
