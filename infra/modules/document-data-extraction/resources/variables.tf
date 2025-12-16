variable "name" {
  description = "Prefix to use for resource names"
  type        = string
}

variable "bucket_policy_arns" {
  description = "The set of policy ARNs for the input and output buckets to attach to the BDA role."
  type        = map(string)
}

variable "project_description" {
  description = "The description of the Bedrock data automation project."
  type        = string
  default     = null
}

variable "kms_encryption_context" {
  description = "The KMS encryption context for the Bedrock data automation project."
  type        = map(string)
  default     = null
}

variable "kms_key_id" {
  description = "The KMS key ID for the Bedrock data automation project."
  type        = string
  default     = null
}

variable "custom_output_config" {
  description = "A list of the BDA custom output configuartion blueprint(s)."
  type = list(object({
    blueprint_arn     = optional(string)
    blueprint_stage   = optional(string)
    blueprint_version = optional(string)
  }))
  default = null
}

variable "standard_output_configuration" {
  description = "Standard output is pre-defined extraction managed by Bedrock. It can extract information from documents, images, videos, and audio."
  type = object({
    audio = optional(object({
      extraction = optional(object({
        category = optional(object({
          state = optional(string)
          types = optional(list(string))
        }))
      }))
      generative_field = optional(object({
        state = optional(string)
        types = optional(list(string))
      }))
    }))
    document = optional(object({
      extraction = optional(object({
        bounding_box = optional(object({
          state = optional(string)
        }))
        granularity = optional(object({
          types = optional(list(string))
        }))
      }))
      generative_field = optional(object({
        state = optional(string)
      }))
      output_format = optional(object({
        additional_file_format = optional(object({
          state = optional(string)
        }))
        text_format = optional(object({
          types = optional(list(string))
        }))
      }))
    }))
    image = optional(object({
      extraction = optional(object({
        category = optional(object({
          state = optional(string)
          types = optional(list(string))
        }))
        bounding_box = optional(object({
          state = optional(string)
        }))
      }))
      generative_field = optional(object({
        state = optional(string)
        types = optional(list(string))
      }))
    }))
    video = optional(object({
      extraction = optional(object({
        category = optional(object({
          state = optional(string)
          types = optional(list(string))
        }))
        bounding_box = optional(object({
          state = optional(string)
        }))
      }))
      generative_field = optional(object({
        state = optional(string)
        types = optional(list(string))
      }))
    }))
  })
  default = null
}

variable "override_config_state" {
  description = "Configuration state for the BDA override."
  type        = string
  default     = null
}

variable "tags" {
  description = "A list of tag keys and values for the Bedrock data automation project."
  type = list(object({
    key   = string
    value = string
  }))
  default = null

}

variable "blueprints_map" {
  description = "the map of unique blueprints with keys as blueprint identifiers and values as blueprint objects"
  type = map(object({
    schema                 = string
    type                   = string
    kms_encryption_context = map(string)
    kms_key_id             = string
    tags = list(object({
      key   = string
      value = string
    }))
  }))
}
