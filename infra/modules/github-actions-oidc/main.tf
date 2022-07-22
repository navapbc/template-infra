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

# Setup assumme role for github actions

data "aws_iam_policy_document" "github" {
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
  assume_role_policy = data.aws_iam_policy_document.github.json
}



# Question: Should this be prefixed, if its single account is there any reason to have 3 of these? maybe because of role permissions? but that can be solved by havthing 3 roles and having the role as a variable in the cd...
# If it is prefixed, do we still needd 3 roles??