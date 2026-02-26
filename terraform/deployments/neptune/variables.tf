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
    cluster_parameter_group = optional(list(object({
      name         = string
      value        = string
      apply_method = string
    })))
    instance_parameter_group_name = string
    instance_parameter_group = optional(list(object({
      name         = string
      value        = any
      apply_method = string
    })))
    instance_count                 = number
    iam_roles                      = list(string)
    apply_immediately              = optional(bool, true)
    preferred_maintenance_window   = optional(string)
    preferred_backup_window        = optional(string)
    backup_retention_period        = optional(number)
    deletion_protection            = bool
    enable_cloudwatch_logs_exports = optional(list(string), [])
    snapshot_identifier            = optional(string)
    allow_major_version_upgrade    = optional(bool, false)
    port                           = optional(number, 8182)
    storage_type                   = optional(string, "standard")
    })
  )

  validation {
    condition = alltrue([
      for db in var.neptune_dbs : alltrue([
        for cpg in db.instance_parameter_group :
        contains(["immediate", "pending-reboot"], cpg.apply_method)
      ])]
    )
    error_message = "The instance_parameter_group objects apply_method must be either 'immediate' or 'pending-reboot'"
  }

  validation {
    condition = alltrue([
      for db in var.neptune_dbs : alltrue([
        for cpg in db.cluster_parameter_group :
        contains(["immediate", "pending-reboot"], cpg.apply_method)
      ])]
    )
    error_message = "The cluster_parameter_group objects apply_method must be either 'immediate' or 'pending-reboot'"
  }
}

variable "internal_cname_domains_enabled" {
  description = "Flag to enable cname domains <environment>.govuk-internal.digital. Disable in test as root dns does not exist"
  type        = bool
  default     = false
}

