variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-1"
}

variable "govuk_environment" {
  type        = string
  description = "Acceptable values are test, integration, staging, production"
}

variable "stackname" {
  type        = string
  description = "Name of the stack, valid options are 'blue' and 'green'"

  validation {
    condition     = var.stackname == "blue" || var.stackname == "green"
    error_message = "stackname must be one of 'blue' or 'green'"
  }
}

variable "engine_version" {
  type        = string
  description = "The engine version of the opensearch cluster"
}

variable "instance_type" { type = string }
variable "instance_count" { type = number }

variable "dedicated_master" {
  type = object({
    instance_count = number
    instance_type  = string
  })
  description = "Dedicated master settings, leave null to disable dedicated master"
  default     = null
}

variable "ebs" {
  type = object({
    volume_size      = number
    volume_type      = string
    throughput       = number
    provisioned_iops = number
  })
  description = "EBS configuration, leave null to disable EBS"
  default     = null
}

variable "tls_security_policy" {
  type        = string
  description = "The pre-canned AWS security policy to enforce for connections to opensearch"
}

variable "zone_awareness_enabled" {
  type    = bool
  default = false
}

variable "elasticsearch6_manual_snapshot_bucket_arns" {
  type        = list(string)
  description = "A list of S3 Bucket ARNS that the manual snapshot role should be able to access"
}
