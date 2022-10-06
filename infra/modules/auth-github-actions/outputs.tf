output "github_actions_role_name" {
  value = aws_iam_role.github_actions.name
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}

output "oidc_thumbprint_github" {
  value = local.oidc_thumbprint_github
}
