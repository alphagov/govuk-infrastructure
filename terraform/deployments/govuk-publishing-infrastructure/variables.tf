variable "govuk_aws_state_bucket" {
  type        = string
  description = "The name of the S3 bucket used for govuk-aws's Terraform state files."
}

variable "govuk_environment" {
  type        = string
  description = "GOV.UK environment where resources are being deployed"
}

variable "force_destroy" {
  type        = bool
  description = "Setting for force_destroy on resources such as S3 buckets and Route53 zones. For use in non-production environments to allow for automated tear-down."
  default     = false
}

variable "frontend_memcached_node_type" {
  type        = string
  description = "Instance type for the Frontend memcached."
}

variable "licensify_documentdb_instance_count" {
  type        = number
  default     = 3
  description = "Number of instances to create for the Licensify DocumentDB cluster"
}

variable "licensify_backup_retention_period" {
  type        = number
  default     = 5
  description = "Number of days to keep Licensify DocumentDB backups for"
}

variable "shared_documentdb_identifier_suffix" {
  type        = string
  default     = ""
  description = "Identifier suffix for shared DocumentDB instances"
}

variable "shared_documentdb_instance_count" {
  type        = number
  default     = 3
  description = "Number of days to keep shared DocumentDB backups for"
}

variable "shared_documentdb_backup_retention_period" {
  type        = number
  default     = 5
  description = "Number of days to keep shared DocumentDB backups for"
}

variable "search_api_lb_arn" {
  type        = string
  description = "The ARN of the search-api-v2 load balancer"
}

variable "search_api_lb_dns_name" {
  type        = string
  description = "The DNS name of the search-api-v2 load balancer"
}

variable "search_api_domain" {
  type        = string
  description = "The domain name of the API gateway"
}

variable "publishing_certificate_arn" {
  type        = string
  description = "The ARN of the publishing certificate"
}

variable "search_api_rate_limit" {
  type        = string
  description = "The rate limit applied to search API over 5 minutes"
}

variable "amazonmq_engine_version" {
  type        = string
  description = "Engine version for publishing AmazonMQ cluster"
}

variable "amazonmq_deployment_mode" {
  type        = string
  default     = "SINGLE_INSTANCE"
  description = "SINGLE_INSTANCE, ACTIVE_STANDBY_MULTI_AZ, or CLUSTER_MULTI_AZ"
}

variable "amazonmq_maintenance_window_start_day_of_week" {
  type        = string
  default     = "MONDAY"
  description = "Day of week for automated maintenance"
}

variable "amazonmq_maintenance_window_start_time_utc" {
  type        = string
  default     = "07:00"
  description = "Time to start automated maintenance"
}

variable "amazonmq_host_instance_type" {
  type        = string
  default     = "mq.t3.micro"
  description = "Instance size for publishing AmazonMQ cluster"
}

variable "amazonmq_govuk_chat_retry_message_ttl" {
  type        = number
  default     = 300000
  description = "Time in miliseconds before messages in the govuk_chat_retry queue expires and are sent back to the govuk_chat_published_documents queue through the dead letter mechanism"
}

variable "allow_high_request_rate_from_cidrs" {
  type        = list(string)
  description = "List of CIDRs from which we allow a higher ratelimit."
  default     = []
}

variable "cache_public_base_rate_limit" {
  type        = number
  description = "An enforced rate limit threshold for the public web ACL"
  default     = 1000
}

variable "cache_public_post_rate_limit" {
  type        = number
  description = "A rate limit threshold for posts to the public web ACL"
  default     = 1000
}

variable "backend_public_base_rate_warning" {
  type        = number
  description = "A warning rate limit threshold for the backend public web ACL"
  default     = 2000
}

variable "backend_public_base_rate_limit" {
  type        = number
  description = "An enforced rate limit threshold for the backend public web ACL"
  default     = 1000
}

variable "backend_public_ja3_denylist" {
  type        = list(string)
  description = "For the backend ALB. List of JA3 signatures for which we should block all requests."
  default     = []
}

variable "waf_log_retention_days" {
  type        = string
  description = "The number of days CloudWatch will retain WAF logs for."
  default     = "30"
}

variable "bouncer_public_base_rate_warning" {
  type        = number
  description = "A warning rate limit threshold for the bouncer public web ACL"
  default     = 2000
}

variable "bouncer_public_base_rate_limit" {
  type        = number
  description = "An enforced rate limit threshold for the bouncer public web ACL"
  default     = 1000
}

variable "fastly_rate_limit_token" {
  type        = string
  description = "Fastly API token for rate limiting"
  default     = "test"
}

variable "office_ips" {
  type        = list(string)
  description = "List of CIDRs from which we consider Office IPs."
  default     = []
}

variable "subdomain_dns_records" {
  type = list(object({
    type  = string
    name  = string
    value = list(string)
    ttl   = number
  }))

  description = "List of arbitrary DNS records that should be present in the the publishing subdomain's hosted zone"
  default     = []

  validation {
    condition = !anytrue([
      for record in var.subdomain_dns_records : endswith(record.name, ".")
    ])

    error_message = "Subdomain DNS record names should not end with a dot"
  }
}

variable "subdomain_delegation_name_servers" {
  type        = map(list(string))
  description = "A map of subdomains and their name servers to create DNS delegation records for. This should be empty outside of production, where the other environments will be delegated from."
  default     = {}

  validation {
    condition     = var.govuk_environment == "production" ? true : length(var.subdomain_delegation_name_servers) == 0
    error_message = "Subdomain delegation name servers should be empty outside of the production environment"
  }

  validation {
    condition = !anytrue([
      for name, _ in var.subdomain_delegation_name_servers : endswith(name, ".")
    ])
    error_message = "Subdomains should not end with a dot"
  }

  validation {
    condition = !anytrue([
      for _, nameservers in var.subdomain_delegation_name_servers : (length(nameservers) < 1)
    ])
    error_message = "Lists of name servers must contain at least one entry"
  }
}
