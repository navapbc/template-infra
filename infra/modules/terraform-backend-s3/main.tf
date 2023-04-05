data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_iam_account_alias" "current" {}

locals {
  tf_state_bucket_name = "${var.project_name}-${data.aws_iam_account_alias.current.account_alias}-${data.aws_region.current.name}-tf-state"
  tf_logs_bucket_name  = "${var.project_name}-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-tf-logs"
  tf_locks_table_name  = "${var.project_name}-tf-state-locks"
}

# Create the dynamodb table required for state locking.

# Options for encryption are an AWS owned key, which is not unique to your account; AWS managed; or customer managed. The latter two options are more secure, and customer managed gives
# control over the key. This allows for ability to restrict access by key as well as policies attached to roles or users. 
# https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html
resource "aws_kms_key" "tf_backend" {
  description = "KMS key for DynamoDB table ${local.tf_locks_table_name}"
  # The waiting period, specified in number of days. After the waiting period ends, AWS KMS deletes the KMS key.
  deletion_window_in_days = "10"
  # Generates new cryptographic material every 365 days, this is used to encrypt your data. The KMS key retains the old material for decryption purposes.
  enable_key_rotation = "true"
}

resource "aws_dynamodb_table" "terraform_lock" {
  name         = local.tf_locks_table_name
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.tf_backend.arn
  }

  point_in_time_recovery {
    enabled = true
  }

}

# Create the S3 bucket used to store terraform state remotely.
resource "aws_s3_bucket" "tf_state" {
  bucket = local.tf_state_bucket_name

  # checkov:skip=CKV_AWS_144:Cross region replication not required by default

  # Prevent accidental destruction a developer executing terraform destory in the wrong directory. Contains terraform state files.
  lifecycle {
    prevent_destroy = true
  }
}

data "aws_iam_policy_document" "topic" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions   = ["SNS:Publish"]
    resources = ["arn:aws:sns:*:*:s3-event-notification-topic"]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.tf_state.arn]
    }
  }
}

resource "aws_sns_topic" "topic" {
  name   = "s3-event-notification-topic"
  policy = data.aws_iam_policy_document.topic.json
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.tf_state.id

  topic {
    topic_arn     = aws_sns_topic.topic.arn
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".log"
  }
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.tf_backend.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "tf_state" {
  bucket                = aws_s3_bucket.tf_state.id
  expected_bucket_owner = data.aws_caller_identity.current.account_id

  rule {
    id     = "move-s3-to-ia"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 15
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }
  }
}

data "aws_iam_policy_document" "tf_state" {
  statement {
    sid = "RequireTLS"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.tf_state.arn,
      "${aws_s3_bucket.tf_state.arn}/*"
    ]

    effect = "Deny"

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = [
        false
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  policy = data.aws_iam_policy_document.tf_state.json
}

# Create the S3 bucket to provide server access logging.
resource "aws_s3_bucket" "tf_log" {
  bucket = local.tf_logs_bucket_name

  # checkov:skip=CKV_AWS_144:Cross region replication not required by default
}

resource "aws_s3_bucket_versioning" "tf_log" {
  bucket = aws_s3_bucket.tf_log.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_log" {
  bucket = aws_s3_bucket.tf_log.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.tf_backend.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "tf_log" {
  bucket = aws_s3_bucket.tf_log.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "tf_log" {
  bucket = aws_s3_bucket.tf_log.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Move all log data to lower cost infrequent-access storage after 30 days.
resource "aws_s3_bucket_lifecycle_configuration" "tf_log" {
  bucket                = aws_s3_bucket.tf_log.id
  expected_bucket_owner = data.aws_caller_identity.current.account_id

  rule {
    id     = "move-s3-to-ia"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 15
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }
  }
}

data "aws_iam_policy_document" "tf_log" {
  statement {
    sid = "RequireTLS"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.tf_log.arn,
      "${aws_s3_bucket.tf_log.arn}/*"
    ]

    effect = "Deny"

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = [
        false
      ]
    }
  }
  statement {
    sid = "S3ServerAccessLogsPolicy"
    principals {
      type = "Service"
      identifiers = [
        "logging.s3.amazonaws.com"
      ]
    }
    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.tf_log.arn}/*"
    ]

    effect = "Allow"

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"

      values = [
        "arn:${data.aws_partition.current.id}:s3:::${aws_s3_bucket.tf_log.id}"
      ]
    }

    condition {
      test     = "StringLike"
      variable = "aws:SourceAccount"

      values = [
        data.aws_caller_identity.current.account_id
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "tf_log" {
  bucket = aws_s3_bucket.tf_log.id
  policy = data.aws_iam_policy_document.tf_log.json
}

resource "aws_s3_bucket_logging" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  target_bucket = aws_s3_bucket.tf_log.id
  target_prefix = "logs/${aws_s3_bucket.tf_state.bucket}/"
}

resource "aws_s3_bucket_logging" "tf_log" {
  bucket = aws_s3_bucket.tf_log.id

  target_bucket = aws_s3_bucket.tf_log.id
  target_prefix = "logs/${aws_s3_bucket.tf_log.bucket}/"
}
