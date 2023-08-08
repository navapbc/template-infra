locals {
  purpose = "access-logs"
}

resource "aws_s3_bucket" "alb" {
  bucket_prefix = "${var.service_name}-${local.purpose}"
  force_destroy = true
  # checkov:skip=CKV2_AWS_62:Ensure S3 buckets should have event notifications enabled
  # checkov:skip=CKV_AWS_18:Ensure the S3 bucket has access logging enabled
  # checkov:skip=CKV_AWS_144:Ensure that S3 bucket has cross-region replication enabled  
  # checkov:skip=CKV_AWS_300:Ensure S3 lifecycle configuration sets period for aborting failed uploads
  # Known issue where Checkov gets confused by multiple rules
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.alb.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "load_balancer_logs_put_access" {
  statement {
    effect = "Allow"
    resources = [
      aws_s3_bucket.alb.arn,
      "${aws_s3_bucket.alb.arn}/*"
    ]
    actions = ["s3:PutObject"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.elb_account_map[data.aws_region.current.name]}:root"]
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lc" {
  count  = var.log_file_transition != [] && var.log_file_deletion != 0 ? 1 : 0
  bucket = aws_s3_bucket.alb.id
  rule {
    id     = "StorageClass"
    status = "Enabled"
    dynamic "transition" {
      for_each = var.log_file_transition
      content {
        days          = transition.value
        storage_class = transition.key
      }
    }
  }
  rule {
    id     = "AbortIncompleteUpload"
    status = "Enabled"
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
  dynamic "rule" {
    for_each = var.log_file_deletion != 0 ? [1] : []
    content {
      id     = "Expiration"
      status = "Enabled"
      expiration {
        days = var.log_file_deletion
      }
    }
  }
  # checkov:skip=CKV_AWS_300:Ensure S3 lifecycle configuration sets period for aborting failed uploads
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.alb.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.alb.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_policy" "bucket_pol" {
  bucket = aws_s3_bucket.alb.id
  policy = data.aws_iam_policy_document.load_balancer_logs_put_access.json
}