variable "manage_method" {
  type        = string
  description = <<EOF
    Method to manage the secret. Options are 'manual' or 'code'.
    Set to 'code' to generate a random secret.
    Set to 'manual' to reference a secret that was manually created and stored in AWS parameter store.
    Defaults to 'code'."
    EOF
  default     = "code"
  validation {
    condition     = can(regex("^(manual|code)$", var.manage_method))
    error_message = "Invalid manage_method. Must be 'manual' or 'code'."
  }
}

variable "secret_store_path" {
  type        = string
  description = <<EOF
    If manage_method is 'code', path to store the secret in AWS parameter store.
    If manage_method is 'manual', path to reference the secret in AWS parameter store.
    EOF
}
