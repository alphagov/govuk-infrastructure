variable "govuk_environment" {
  type        = string
  description = "GOV.UK environment name"
}

variable "databases" {
  type        = map(number)
  description = "Map of app names to database IDs"
}

variable "engine_version" {
  type        = string
  default     = "8.0"
  description = "Valkey version"
}

variable "node_type" {
  type        = string
  default     = "cache.m7g.xlarge"
  description = "ElastiCache node type"
}
