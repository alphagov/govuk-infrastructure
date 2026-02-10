variable "name" {
  type = string
}

variable "extra_bucket_policies" {
  type        = list(string)
  description = "extra bucket policies to apply to this bucket. List of json policies"
  default     = []
}

variable "AES256_encryption_configuration" {
  type        = bool
  description = "Whether to use AES256 as the algorithm for server side encryption. If false, the caller should set their own configuration"
  default     = true
  nullable    = false
}

variable "versioning_enabled" {
  type        = bool
  description = "Whether S3 bucket object versioning should be enabled"
  default     = true
  nullable    = false
}

variable "govuk_environment" {
  type        = string
  description = "Acceptable values are test, integration, staging, production"
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
  nullable    = true
}

