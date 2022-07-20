data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Create the S3 bucket with a unique prefix from terraform.workspace.
resource "aws_s3_bucket" "example" {
  bucket = "${var.prefix}-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-bucket"

}