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

variable "service_name" {
  type = string
}

variable "assets_url" {
  type        = string
  description = "URL of the Assets service"
}

variable "content_store_url" {
  type        = string
  description = "URL of the Content Store service"
}

variable "static_url" {
  type        = string
  description = "URL of the Static service"
}
