variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-1"
}

variable "read_snapshots_from_environments" {
  type        = list(string)
  description = "A list of GOV.UK environment names which this ES cluster should be able to read snapshots from"
  nullable    = false
}

variable "account_ids_allowed_to_read_domain_snapshots" {
  type        = list(string)
  description = "Which accounts can read from the snapshots bucket"
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
    }))
    endpoint_tls_security_policy = optional(string)
    ebs_options = optional(object({
      volume_size = number
      volume_type = string
      throughput  = number
      iops        = optional(number)
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
    }))
    endpoint_tls_security_policy = optional(string)
    ebs_options = optional(object({
      volume_size = number
      volume_type = string
      throughput  = number
      iops        = optional(number)
    }))

    // The following options only exist to allow the Search ES6 cluster to be imported and should not be used in the future
    prefix_colour_instead_of_suffix = optional(bool, false)
    disable_audit_logs              = optional(bool, false)
    log_group_name_overrides = optional(object({
      index_slow_logs  = string
      search_slow_logs = string
      error_logs       = string
    }))
    log_retention_in_days            = optional(number)
    log_group_prefix_override        = optional(string)
    inline_access_policy_declaration = optional(bool, false)
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

variable "use_aws_elasticsearch_domain_resource_for_green_cluster" {
  type        = bool
  description = "Use an aws_elasticsearch_domain resource instead of aws_opensearch_domain to allow search ES cluster to be imported"
  deprecated  = "Do not set this option except when importing the existing Search ElasticSearch cluster"
  default     = false
  nullable    = false

  validation {
    condition = (
      var.use_aws_elasticsearch_domain_resource_for_green_cluster == true && var.green_cluster_options != null && var.green_cluster_options.engine_version == "6.8"
    ) || var.use_aws_elasticsearch_domain_resource_for_green_cluster == false
    error_message = "This option must ONLY be set when importing the original Search Elasticsearch 6 cluster."
  }
}
