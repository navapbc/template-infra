# Block public access
resource "aws_s3_bucket_public_access_block" "storage" {
  bucket = aws_s3_bucket.storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create policy for read/write access
# Attach this policy to roles that need access to the bucket
resource "aws_iam_policy" "storage_access" {
  name = "${var.name}-access"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:PutObject",
        ],
        Effect   = "Allow",
        Resource = ["arn:aws:s3:::${var.name}/*"]
      }
    ]
  })
}
