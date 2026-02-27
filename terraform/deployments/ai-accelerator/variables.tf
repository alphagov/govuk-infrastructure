variable "aws_region" {
  type        = string
  description = "AWS region to deploy into"
  nullable    = false
}

variable "govuk_environment" {
  type        = string
  description = "GOV.UK AWS environment name"
  nullable    = false
}

variable "current_live_domain" {
  type        = string
  description = "Either blue, or green, specifying the current live OpenSearch domain"
  nullable    = false

  validation {
    condition     = var.current_live_domain == "blue" || var.current_live_domain == "green"
    error_message = "var.current_live_domain must be either 'blue', or 'green'"
  }

  validation {
    condition = (
      (var.current_live_domain == "blue" && var.launch_blue_domain)
      || (var.current_live_domain == "green" && var.launch_green_domain)
    )
    error_message = "var.current_live_domain cannot be set to a domain that hasn't been launched."
  }
}

variable "launch_blue_domain" {
  type        = bool
  description = "Launch the blue OpenSearch domain"
  nullable    = false
}

variable "blue_cluster_options" {
  type = object({
    engine         = optional(string, "OpenSearch")
    engine_version = string
    dedicated_master = optional(object({
      instance_count = number
      instance_type  = string
    }))
    instance_count         = number
    instance_type          = string
    zone_awareness_enabled = optional(bool, true)
    advanced_security_options = optional(object({
      anonymous_auth_enabled         = optional(bool, false)
      internal_user_database_enabled = optional(bool, true)
    }), {})
    endpoint_tls_security_policy = optional(string)
    ebs_options = optional(object({
      volume_size = number
      volume_type = string
      throughput  = number
    }))
  })
  default  = null
  nullable = true

  validation {
    condition     = var.launch_blue_domain == false || var.blue_cluster_options != null
    error_message = "var.blue_cluster_options must be set if var.launch_blue_domain is true."
  }
}

variable "launch_green_domain" {
  type        = bool
  description = "Launch the green OpenSearch domain"
  nullable    = false
}

variable "green_cluster_options" {
  type = object({
    engine         = optional(string, "OpenSearch")
    engine_version = string
    dedicated_master = optional(object({
      instance_count = number
      instance_type  = string
    }))
    instance_count         = number
    instance_type          = string
    zone_awareness_enabled = optional(bool, true)
    advanced_security_options = optional(object({
      anonymous_auth_enabled         = optional(bool, false)
      internal_user_database_enabled = optional(bool, true)
    }), {})
    endpoint_tls_security_policy = optional(string)
    ebs_options = optional(object({
      volume_size = number
      volume_type = string
      throughput  = number
    }))
  })
  default  = null
  nullable = true

  validation {
    condition     = var.launch_green_domain == false || var.green_cluster_options != null
    error_message = "var.green_cluster_options must be set if var.launch_green_domain is true."
  }
}

variable "read_snapshots_from_environments" {
  type        = list(string)
  description = "The environment names which this deployment should be able to read snapshots from as well as its own"
  default     = []
  nullable    = false

  validation {
    condition = alltrue(
      [for env in var.read_snapshots_from_environments : contains(["test", "integration", "staging", "production"], env)]
    )
    error_message = "All values in var.read_snapshots_from_environment must be one of 'test', 'integration', 'staging', or 'production'."
  }
}

variable "account_ids_allowed_to_read_domain_snapshots" {
  type        = list(string)
  description = "A list of AWS Account IDS (in addition to the current) which will be allowed to read snapshots from the snapshot bucket created by this module"
  default     = []
  nullable    = false

  validation {
    condition = alltrue(
      [
        for env in var.account_ids_allowed_to_read_domain_snapshots : contains(
          [
            "172025368201", # Production
            "696911096973", # Staging
            "210287912431", # Integration
            "430354129336", # Test
          ],
        )
      ]
    )
    error_message = "var.account_ids_allowed_to_read_snapshots must only contain recognised GOV.UK AWS Account IDs."
  }
}
