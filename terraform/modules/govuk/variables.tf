variable "vpc_id" {
  type = string
}

variable "govuk_app_domain_external" {
  type = string
}

variable "govuk_website_root" {
  type = string
}

variable "mongodb_host" {
  type = string
}

variable "statsd_host" {
  type = string
}

variable "private_subnets" {
  description = "Subnet IDs to use for non-Internet-facing resources."
  type        = list
}

# TODO: pull common vars up from the app modules into here so that they can vary by environment.
