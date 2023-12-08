variable "name" {
  type        = string
  description = "Name to give the VPC. Will be added to the VPC under the 'network_name' tag."
}

variable "database_subnet_group_name" {
  type        = string
  description = "Name of the database subnet group"
}

variable "nat_gateway_config" {
  # nat gateways are pricey, unless outgoing traffic
  # is part of your service, one should be enough
  # (i.e. to allow your app to fetch some resources on startup)
  type        = string
  default     = "none"
  description = "How many NAT gateways (which can be pricey) to create. None, a single one that is shared across all subnets, one per availability zone, or one per private subnet"
  validation {
    condition     = contains(["none", "shared", "per_az", "per_subnet"], var.nat_gateway_config)
    error_message = "Allowed values for nat_gateway_config are 'none', 'shared', 'per_az', 'per_subnet'"
  }
}
