output "access_policy_arn" {
  value = aws_iam_policy.storage_access.arn
}

output "kms_key_arn" {
  value = aws_kms_key.storage.arn
}
