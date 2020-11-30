variable "command" {
  type        = list
  default     = ["foreman", "run", "web"]
  description = "The Docker CMD instruction, in exec form."
}

variable "execution_role_arn" {
  type = string
}

variable "govuk_app_domain_external" {
  type = string
}

variable "govuk_app_domain_internal" {
  type = string
}

variable "govuk_website_root" {
  type = string
}

variable "image_tag" {
  description = "Container Image Tag"
  type        = string
}

variable "mesh_name" {
  type = string
}

variable "mesh_subdomain" {
  type    = string
  default = "publishing-api"
}

variable "redis_host" {
  type = string
}

variable "redis_port" {
  type    = number
  default = 6379
}

variable "statsd_host" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "sentry_environment" {
  type = string
}

variable "service_discovery_namespace_name" {
  type = string
}

variable "service_name" {
  type        = string
  description = "The ECS Service name, e.g. publishing-api-web or publishing-api-worker"
}

variable "assume_role_arn" {
  type        = string
  description = "(optional) AWS IAM role to assume. Uses the role from the environment by default."
  default     = null
}
