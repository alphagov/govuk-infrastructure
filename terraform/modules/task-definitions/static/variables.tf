variable "image_tag" {
  description = "Container Image Tag"
  type        = string
}

variable "mesh_name" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "sentry_environment" {
  type = string
}

variable "assume_role_arn" {
  type        = string
  description = "(optional) AWS IAM role to assume. Uses the role from the environment by default."
  default     = null
}

variable "service_name" {
  type = string
}

variable "redis_host" {
  type = string
}

variable "redis_port" {
  type    = number
  default = 6379
}

variable "assets_url" {
  type        = string
  description = "URL of the Assets service"
}

variable "service_discovery_namespace_name" {
  type = string
}

variable "statsd_host" {
  type = string
}

variable "govuk_website_root" {
  type = string
}

variable "govuk_app_domain_external" {
  type = string
}
