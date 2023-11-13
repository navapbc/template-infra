variable "service_name" {
  description = "name of the service, to be used for infra structure resource naming"
  validation {
    condition     = can(regex("^[-_\\da-z]+$", var.service_name))
    error_message = "use only lower case letters, numbers, dashes, and underscores"
  }
}

variable "image_tag" {
  type        = string
  description = "The tag of the image to deploy"
}

variable "image_repository_name" {
  type        = string
  description = "The name of the container image repository"
}

variable "external_image_url" {
  type        = string
  description = "A non-AWS container image repository. If this is not empty, this takes precedence over image_repository_name"
  default     = ""
}

variable "desired_instance_count" {
  type        = number
  description = "Number of instances of the task definition to place and keep running."
  default     = 1
}

variable "cpu" {
  type        = number
  default     = 256
  description = "Number of cpu units used by the task, expessed as an integer value, e.g 512 "
}

variable "memory" {
  type        = number
  default     = 512
  description = "Amount (in MiB) of memory used by the task. e.g. 2048"
}


variable "container_port" {
  type        = number
  description = "The port number on the container that's bound to the user-specified"
  default     = 8000
}

variable "vpc_id" {
  type        = string
  description = "Uniquely identifies the VPC."
}

variable "subnet_ids" {
  type        = list(any)
  description = "Private subnet id from vpc module"
}

variable "db_vars" {
  description = "Variables for integrating the app service with a database"
  type = object({
    security_group_ids         = list(string)
    app_access_policy_arn      = string
    migrator_access_policy_arn = string
    connection_info = object({
      host        = string
      port        = string
      user        = string
      db_name     = string
      schema_name = string
    })
  })
  default = null
}

variable "container_env_vars" {
  type        = list(map(string))
  description = "Additional environment variables to pass to the container definition"
  default     = []
}

variable "container_secrets" {
  type        = list(map(string))
  description = "AWS secrets to pass to the container definition"
  default     = []
}

variable "container_read_only" {
  type        = bool
  description = "Whether the container root filesystem should be read-only"
  default     = true
}

#-------------------
# Healthcheck
#-------------------

variable "healthcheck_path" {
  type        = string
  description = "The path to the application healthcheck"
  default     = "/health"
}

variable "healthcheck_type" {
  type        = string
  description = "Whether to configure a curl or wget healthcheck. curl is more common. use wget for alpine-based images"
  default     = "wget"
  validation {
    condition     = contains(["curl", "wget"], var.healthcheck_type)
    error_message = "choose either: curl or wget"
  }
}

variable "healthcheck_matcher" {
  type        = string
  description = "The response codes that indicate healthy to the ALB"
  default     = "200-299"
}

variable "healthcheck_start_period" {
  type        = number
  description = "The optional grace period to provide containers time to bootstrap in before failed health checks count towards the maximum number of retries"
  default     = 0
}

variable "enable_container_healthcheck" {
  type        = bool
  description = "The ALB healthcheck is mandatory, but the container healthcheck can be disabled if desired"
  default     = true
}
