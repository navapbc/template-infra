# Example of what is in the Token
# {
#   "issuer": "https://token.actions.githubusercontent.com",
#   "jwks_uri": "https://token.actions.githubusercontent.com/.well-known/jwks",
#   "subject_types_supported": [
#     "public",
#     "pairwise"
#   ],
#   "response_types_supported": [
#     "id_token"
#   ],
#   "claims_supported": [
#     "sub",
#     "aud",
#     "exp",
#     "iat",
#     "iss",
#     "jti",
#     "nbf",
#     "ref",
#     "repository",
#     "repository_id",
#     "repository_owner",
#     "repository_owner_id",
#     "run_id",
#     "run_number",
#     "run_attempt",
#     "actor",
#     "actor_id",
#     "workflow",
#     "head_ref",
#     "base_ref",
#     "event_name",
#     "ref_type",
#     "environment",
#     "job_workflow_ref",
#     "repository_visibility"
#   ],
#   "id_token_signing_alg_values_supported": [
#     "RS256"
#   ],
#   "scopes_supported": [
#     "openid"
#   ]
# }

# Setup OIDC Provider on AWS for github actions
# Get the thumbprint
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates.0.sha1_fingerprint]
}

# Setup assumme role policy for github actions

data "aws_iam_policy_document" "github_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [var.tr_pattern_sub]
    }
  }
}

resource "aws_iam_role" "github" {
  name               = "github-actions-assume-role"
  description        = "Service role required for Github Action to deploy application resources into the account."
  assume_role_policy = data.aws_iam_policy_document.github.json
}

# Create permissions the role is allowed to execute on the aws account
# data "aws_iam_policy_document" "github_permissions" {
#   statement {
#     sid = "GithubActionsPermissionsECR"
#     actions = [
#       "ecr:BatchCheckLayerAvailability",
#       "ecr:BatchGetImage",
#       "ecr:CompleteLayerUpload",
#       "ecr:GetDownloadUrlForLayer",
#       "ecr:GetLifecyclePolicy",
#       "ecr:InitiateLayerUpload",
#       "ecr:PutImage",
#       "ecr:UploadLayerPart"]
#     effect = "Allow"
#     resources = ["*"]
#     principals {
#       type        = "AWS"
#       identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
#     }
#   }
#   statement {
#     sid = "GithubActionsPermissionsECS"
#     actions = ["ecs:*"]
#     effect = "Allow"
#     resources = ["*"]
#     principals {
#       type        = "AWS"
#       identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
#     }
#   }
# }

# resource "aws_iam_policy" "github_permissions" {
#   name        = "github-actions-permissions-policy"
#   description = "Permissions for Github Actions service role"
#   policy      = data.aws_iam_policy_document.github_permissions.json
# }

# resource "aws_iam_role_policy_attachment" "replication_role_attach" {
#   policy_arn = aws_iam_policy.github_permissions.arn
#   role       = aws_iam_role.github.name
#   depends_on = [
#     aws_iam_role.github
#   ]
# }