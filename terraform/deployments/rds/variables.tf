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

variable "databases" {
  description = "Databases to create and their configuration."

  type = map(object({
    name                               = string
    project                            = optional(string, "GOV.UK - Other")
    instance_class                     = string
    allocated_storage                  = number
    iops                               = optional(number)
    storage_throughput                 = optional(number)
    storage_alarm_threshold_percentage = optional(number, 10)
    deletion_protection                = optional(bool, true)
    engine                             = string
    engine_version                     = string
    engine_params = map(object({
      value        = any
      apply_method = optional(string, "immediate")
    }))
    engine_params_family         = optional(string)
    maintenance_window           = optional(string)
    backup_window                = optional(string)
    backup_retention_period      = optional(number)
    new_name                     = optional(string)
    snapshot_identifier          = optional(string)
    apply_immediately            = optional(bool)
    allow_major_version_upgrade  = optional(bool, false)
    auto_minor_version_upgrade   = optional(bool, true)
    performance_insights_enabled = bool

    // It would be better if all replica related things where grouped into an object
    // but for now I want to be able to get a clean plan without changes to tfc-configuration
    has_read_replica          = optional(bool, false)
    replica_engine_version    = optional(string)
    replica_apply_immediately = optional(bool)
    replica_multi_az          = optional(bool)
  }))

  validation {
    condition = alltrue([
      for database in var.databases : alltrue([
        for engine_param in database.engine_params :
        contains(["immediate", "pending-reboot"], engine_param.apply_method)
      ])]
    )
    error_message = "The engine_params objects apply_method must be either 'immediate' or 'pending-reboot'"
  }

  validation {
    condition     = alltrue([for database in var.databases : contains(["mysql", "postgres"], database.engine)])
    error_message = "The engine must be one of mysql or postgres"
  }
}

variable "database_admin_username" {
  type        = string
  default     = "aws_db_admin"
  description = "RDS root account username."
}

variable "multi_az" {
  type        = bool
  description = "Set to true to deploy the RDS instance in multiple AZs."
  default     = false
}

variable "maintenance_window" {
  type        = string
  description = "The window to perform maintenance in"
  default     = "Mon:04:00-Mon:06:00"
}

variable "backup_window" {
  type        = string
  description = "The daily time range during which automated backups are created if automated backups are enabled."
  default     = "01:00-03:00"
}

variable "backup_retention_period" {
  type        = number
  description = "Backup retention period in days."
  default     = 7
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Set to true to NOT create a final snapshot when the cluster is deleted."
  default     = false
}

variable "terraform_create_rds_timeout" {
  type        = string
  description = "Set the timeout time for AWS RDS creation."
  default     = "2h"
}

variable "terraform_update_rds_timeout" {
  type        = string
  description = "Set the timeout time for AWS RDS modification."
  default     = "2h"
}

variable "terraform_delete_rds_timeout" {
  type        = string
  description = "Set the timeout time for AWS RDS deletion."
  default     = "2h"
}
