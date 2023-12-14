resource "aws_s3_bucket" "storage" {
  bucket        = var.name
  force_destroy = false
}
