variable "prefix" {
  type        = string
  description = "Special identifer that will allow resources to deploy without interfering with other common resources."
}

variable "alb_name" {
  type        = string
  description = "A user-generated string that used to identify the Application Load Balancer."
}

variable "vpc_id" {
  type        = string
  description = "Uniquely identifies the VPC."
}

variable "subnets" {
  type        = list(any)
  description = "Subnets that the application load balancer will service."
}
