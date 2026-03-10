# The configuration of the "caches" variable is in
# "govuk-infrastructure/terraform/deployments/elasticache/variables.tf".
# Only the name and description are required, the rest of the parameters
# are optional, with their defaults as follows:
#   name                       = required
#   description                = required
#   num_cache_clusters         = optional (default = "1")
#   node_type                  = optional (default = "cache.t4g.small")
#   automatic_failover_enabled = optional (default = false)
#   multi_az_enabled           = optional (default = false)
#   engine                     = optional (default = "valkey")
#   engine_version             = optional (default = "8.0")
#   family                     = optional (default = "valkey8")
# If any further parameters need to be modified in the
# elasticache parameter group, they need to be configured here
# for them to take effect, otherwise the values will be ignored:
#   parameters = {
#     maxmemory-policy = optional (default = "noeviction")
#   }
caches = {}
