variable "name" {
  type        = string
  description = "The bucket and IAM policy name. NOTE: This must be a globally unique name for AWS S3"

  validation {
    condition     = startswith(var.name, "govuk-")
    error_message = "The name of the bucket should follow the format 'govuk-{environment}-{purpose}'"
  }
}

variable "extra_bucket_policies" {
  type        = list(string)
  description = "Extra bucket policies to apply to this bucket. List of json policies"
  default     = []
  nullable    = false
}

variable "versioning_enabled" {
  type        = bool
  description = "Whether S3 bucket object versioning should be enabled"
  default     = true
  nullable    = false
}

variable "lifecycle_rules" {
  type = list(object({
    status = string
    id     = string
    abort_incomplete_multipart_upload = optional(object({
      days_after_initiation = optional(number)
    }))
    expiration = optional(object({
      date                         = optional(string)
      days                         = optional(number)
      expired_object_delete_number = optional(bool)
    }))
    filter = optional(object({
      and = optional(object({
        object_size_greater_than = optional(number)
        object_size_less_than    = optional(number)
        prefix                   = optional(string)
        tags = optional(list(object({
          key   = string
          value = string
        })))

      }))
      object_size_greater_than = optional(number)
      object_size_less_than    = optional(number)
      prefix                   = optional(string)
      tag = optional(object({
        key   = string
        value = string
      }))
    }))
    noncurrent_version_expiration = optional(object({
      noncurrent_days           = optional(number)
      newer_noncurrent_versions = optional(number)
    }))
    noncurrent_version_transition = optional(object({
      storage_class             = optional(string)
      noncurrent_days           = optional(number)
      newer_noncurrent_versions = optional(number)
    }))
    transition = optional(object({
      date          = optional(string)
      days          = optional(number)
      storage_class = number
    }))
  }))
  description = "Bucket lifecycle rules and configuration see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration"
  default     = []
  nullable    = false
}

variable "object_lock_config" {
  type = list(object({
    rule = object({
      default_retention = object({
        mode  = string
        days  = optional(number)
        years = optional(number)
      })
    })
  }))
  description = "Bucket object lock config can help prevent Amazon S3 objects from being deleted or overwritten for a fixed amount of time or indefinitely. Object Lock uses a write-once-read-many (WORM) model to store objects."
  default     = []
  nullable    = false
}

variable "enable_public_access_block" {
  type        = bool
  description = "Whether S3 bucket should block public access"
  default     = true
  nullable    = false
}

variable "access_logging_config" {
  type = object({
    target_bucket = string
    target_prefix = string
    target_object_key_format = optional(object({
      simple_prefix = optional(bool)
      partitioned_prefix = optional(object({
        partition_date_source = string
      }))
    }))
  })
  description = "Ship S3 access logging to another target bucket"
  default     = null
}
