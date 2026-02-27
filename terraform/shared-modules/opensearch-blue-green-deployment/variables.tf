variable "opensearch_domain_name" {
  type        = string
  description = "Name for this opensearch domain, for blue/green deploys this will be suffixed with -blue or -green"
  nullable    = false

  validation {
    condition     = length(var.opensearch_domain_name) >= 1
    error_message = "var.opensearch_domain_name must not be an empty string"
  }

  validation {
    condition     = length(regexall("^[a-z0-9-]+$", var.opensearch_domain_name)) > 0
    error_message = "var.opensearch_domain_name must only contain lowercase letters, numbers, and hyphens."
  }

  validation {
    // These conditions are because the name needs to be valid within an S3 bucket name 
    condition = (
      // Length of domain < Max length of s3 bucket name - environment name legnth - s3 bucket name template
      length(var.opensearch_domain_name) < (63 - length(var.govuk_environment) - length("govuk---${local.bucket_suffix}"))
    )
    error_message = "var.opensearch_domain_name must not be too long, when interpolated in 'govuk-<env>-<opensearch_domain>-${local.bucket_suffix}' the entire string must be 63 or fewer characters."
  }
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

  validation {
    condition     = var.blue_cluster_options == null || var.blue_cluster_options.zone_awareness_enabled == false || var.blue_cluster_options.instance_count >= 3
    error_message = "If var.blue_cluster_options.zone_awareness_enabled is true then var.blue_cluster_options.instance_count must be 3 or more."
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

  validation {
    condition     = var.green_cluster_options == null || var.green_cluster_options.zone_awareness_enabled == false || var.green_cluster_options.instance_count >= 3
    error_message = "If var.green_cluster_options.zone_awareness_enabled is true then var.green_cluster_options.instance_count must be 3 or more."
  }
}

variable "govuk_environment" {
  type        = string
  description = "Name of the GOV.UK Environment into which this is being deployed"
  nullable    = false
}

variable "secrets_manager_prefix" {
  type        = string
  description = "The name to prefix the Secrets Manager Secret with (e.g. govuk/govuk-ai-accelerator), this will have /opensearch appended"
  nullable    = false
}

variable "read_snapshots_from_environments" {
  type        = list(string)
  description = "The environment names which this deployment should be able to read snapshots from as well as from its own"
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

variable "s3_bucket_custom_suffix" {
  type        = string
  description = "Custom s3 snapshot bucket suffix, will override the default of 'opensearch-snapshots'"
  default     = null
  nullable    = true
}
