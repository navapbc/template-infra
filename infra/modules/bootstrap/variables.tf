variable "state_bucket_name" {
  type        = string
  description = "Name of the bucket where terraform state is stored"
}
variable "tf_logging_bucket_name" {
  type        = string
  description = "Name if the bucket where terraform logs are store"
}
variable "dynamodb_table" {
  type        = string
  description = "Name of the dynamodb table used for state locking"
}
        