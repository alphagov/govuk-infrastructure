variable "govuk_environment" {
  type        = string
  description = "Environment name"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-1"
}

variable "govuk_aws_state_bucket" {
  type        = string
  description = "Bucket where govuk-aws state is stored"
}

variable "neptune_dbs" {
  description = "Neptune databases to create and their configuration."

  type = map(object({
    name               = string
    project            = optional(string, "GOV.UK - Other")
    instance_class     = optional(string, "t4g.medium")
    cluster_identifier = string
    engine             = string
    engine_version     = string
    family             = string
    serverless_config = optional(object({
      max_capacity = number
      min_capacity = number
    }))
    cluster_parameter_group_name = string
    cluster_parameter_group = list(object({
      name         = string
      value        = string
      apply_method = string
    }))
    instance_parameter_group_name = string
    instance_parameter_group = list(object({
      name         = string
      value        = any
      apply_method = string
    }))
    instance_count                 = number
    iam_roles                      = list(string)
    apply_immediately              = optional(bool, true)
    preferred_maintenance_window   = optional(string)
    preferred_backup_window        = optional(string)
    backup_retention_period        = optional(number)
    deletion_protection            = bool
    enable_cloudwatch_logs_exports = bool
    snapshot_identifier            = optional(string)
    apply_immediately              = optional(bool)
    allow_major_version_upgrade    = optional(bool, false)
    port                           = optional(number, 8182)
    storage_type                   = optional(string, "standard")
    project                        = string
    })
  )
}

