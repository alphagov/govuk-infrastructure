variable "govuk_environment" {
  type        = string
  description = "GOV.UK environment name"
}

variable "caches" {
  type = map(object({
    name                       = string
    description                = string
    num_cache_clusters         = optional(string, "1")
    node_type                  = optional(string, "cache.t4g.small")
    automatic_failover_enabled = optional(bool, false)
    multi_az_enabled           = optional(bool, false)
    engine                     = optional(string, "valkey")
    engine_version             = optional(string, "8.0")
    family                     = optional(string, "valkey8")

    # If any further parameters need to be modified in the
    # elasticache parameter group, they need to be configured here
    # for them to take effect, otherwise the values will be ignored:
    parameters = optional(object({
      maxmemory-policy = optional(string, "noeviction")
    }), {})
  }))
}
