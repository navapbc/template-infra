data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_policy" "cognito_access" {
  name   = "${var.name}-cognito-access"
  policy = data.aws_iam_policy_document.cognito_access.json
}

data "aws_iam_policy_document" "cognito_access" {
  statement {
    actions   = ["cognito-idp:*"]
    effect    = "Allow"
    resources = ["arn:aws:cognito-idp:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:userpool/${var.cognito_user_pool_id}"]
  }
}
