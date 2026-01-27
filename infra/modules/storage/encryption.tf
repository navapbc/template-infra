resource "aws_kms_key" "storage" {
  count = var.use_aws_managed_encryption ? 0 : 1

  description = "KMS key for bucket ${var.name}"
  # The waiting period, specified in number of days. After the waiting period ends, AWS KMS deletes the KMS key.
  deletion_window_in_days = "10"
  # Generates new cryptographic material every 365 days, this is used to encrypt your data. The KMS key retains the old material for decryption purposes.
  enable_key_rotation = "true"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "storage" {
  bucket = aws_s3_bucket.storage.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.use_aws_managed_encryption ? null : aws_kms_key.storage[0].arn
      sse_algorithm     = var.use_aws_managed_encryption ? "AES256" : "aws:kms"
    }
    bucket_key_enabled = true
  }
}
