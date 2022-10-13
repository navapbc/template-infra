output "image_repository_name" {
  value = local.image_repository_name
}

output "pull_access_policy_arn" {
  value = aws_iam_policy.pull_access.arn
}

output "push_access_policy_arn" {
  value = aws_iam_policy.push_access.arn
}
