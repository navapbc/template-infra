############################################################################################
## A module for retrieving an existing Cognito User Pool and App Client
############################################################################################
data "aws_cognito_user_pools" "existing_user_pools" {
  name = var.name
}

data "aws_cognito_user_pool_clients" "existing_user_pool_clients" {
  user_pool_id = tolist(data.aws_cognito_user_pools.existing_user_pools.ids)[0]
}

data "aws_ssm_parameter" "existing_user_pool_client_secret" {
  name = var.client_secret_ssm_name
}

data "aws_iam_policy" "existing_cognito_access_policy" {
  name = var.user_pool_access_policy_name
}
