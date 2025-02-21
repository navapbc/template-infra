variable "service_name" {
  type        = string
  description = "Name of the service these secrets belong to"
}

variable "secrets" {
  type = map(object({
    manage_method     = string
    secret_store_name = string
  }))
  description = "Map of secret configurations"

  validation {
    condition     = alltrue([for s in values(var.secrets) : can(regex("^(manual|generated)$", s.manage_method))])
    error_message = "Invalid manage_method. Must be 'manual' or 'generated'."
  }
}
