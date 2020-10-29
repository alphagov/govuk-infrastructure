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

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "sentry_environment" {
  type = string
}

variable "statsd_host" {
  type = string
}

variable "service_discovery_namespace_name" {
  type = string
}

variable "asset_host" {
  type = string
}
