variable "vpc_name" {
  type        = string
  description = "VPC Name"
}

variable "vpc_cidr" {
  # e.g. "10.0.0.0/20"
  type        = string
}

variable "private_subnets" {
  # e.g. ["10.0.0.0/23", "10.0.2.0/23", "10.0.4.0/23"]
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  # e.g. ["10.0.10.0/23", "10.0.12.0/23", "10.0.14.0/23"]
  type        = list(string)
  default     = []
}

variable "single_nat_gateway" {
  # nat gateways are pricey, unless outgoing traffic
  # is part of your service, one should be enough
  # (i.e. to allow your app to fetch some resources on startup)
  type        = bool
  default     = true
}