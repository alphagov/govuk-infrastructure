variable "govuk_environment" {
  type        = string
  description = "Name of the GOV.UK Environment into which this is being deployed"
  nullable    = false
}

variable "opensearch_domain_name" {
  type        = string
  description = "Name for this opensearch domain, for blue/green stacks this will be suffixed with -blue or -green"
  nullable    = false
}

variable "cloudwatch_log_retention_in_days" {
  type        = number
  description = "How long to retain OpenSearch logs in CloudWatch Logs"
  default     = 365
  nullable    = false
}

variable "engine" {
  type        = string
  description = "Engine, either Elasticsearch or OpenSearch"
  default     = "OpenSearch"
  nullable    = false

  validation {
    condition     = var.engine == "OpenSearch" || var.engine == "Elasticsearch"
    error_message = "var.engine must either be OpenSearch or Elasticsearch"
  }
}

variable "engine_version" {
  type        = string
  description = "The OpenSearch engine version"
  nullable    = false
}

variable "dedicated_master" {
  type = object({
    instance_count = number
    instance_type  = string
  })
  description = "Dedicated master configuration, leave null to disable dedicated master"
  default     = null
}

variable "instance_count" {
  type        = number
  description = "Number of OpenSearch nodes"
  nullable    = false
}

variable "instance_type" {
  type        = string
  description = "Instance type of the OpenSearch nodes"
  nullable    = false
}

variable "zone_awareness_enabled" {
  type        = bool
  description = "Whether to enable OpenSearch AWS Availability Zone awareness"
  default     = true
  nullable    = false

  validation {
    condition     = var.zone_awareness_enabled == false || var.instance_count >= 3
    error_message = "If var.zone_awareness_enabled is true then var.instance_count must be 3 or more."
  }
}

variable "multi_az_with_standby_enabled" {
  type        = bool
  description = "Whether a multi-AZ domain is turned on with a standby AZ."
  default     = true
  nullable    = false

  validation {
    condition     = var.multi_az_with_standby_enabled == false || !startswith(var.instance_type, "t")
    error_message = "If using t* instance types you must set var.multi_az_with_standby_enabled to false."
  }
}

variable "advanced_security_options" {
  type = object({
    anonymous_auth_enabled         = optional(bool, false)
    internal_user_database_enabled = optional(bool, true)
    master_user_options = object({
      master_user_name     = string
      master_user_password = string
    })
  })
  description = "OpenSearch Advanced Security options"
  sensitive   = true
  nullable    = false
}

variable "custom_endpoint" {
  type        = string
  description = "The custom CNAME which points to the OpenSearch domain"
  nullable    = false

  validation {
    condition     = endswith(var.custom_endpoint, "govuk-internal.digital")
    error_message = "var.custom_endpoint must be a govuk-internal.digital domain."
  }
}

variable "endpoint_tls_security_policy" {
  type        = string
  description = "The TLS Security Policy to apply to the OpenSearch domain endpoint. The default is for TLS version 1.2 to 1.3 with perfect forward secrecy cipher suites"
  default     = "Policy-Min-TLS-1-2-PFS-2023-10"
}

variable "ebs_options" {
  type = object({
    volume_size = number
    volume_type = optional(string, "gp3")
    throughput  = number
  })
  description = "Node EBS volume options, if left null, no EBS volumes will be attached to data nodes in the nodes"
  nullable    = true
  default     = null

  validation {
    condition     = startswith(var.instance_type, "t") && var.ebs_options != null
    error_message = "var.ebs_options must be set if you are using a t* instance type"
  }

  validation {
    condition     = var.ebs_options == null || (var.ebs_options.volume_type == "gp3" ? var.ebs_options.throughput != null : true)
    error_message = "If var.ebs_options.volume_type is gp3 (which is the default) then a throughput must be specified."
  }
}

variable "security_group_ids" {
  type        = list(string)
  description = "A list of AWS Security Group IDs to attach to the domain"
  nullable    = false
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of AWS VPC Subnet IDs in which to deploy the OpenSearch nodes"
  nullable    = false
}
