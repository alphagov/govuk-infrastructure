variable "vpc_id" {
  type = string
}

variable "govuk_app_domain_external" {
  type = string
}

variable "govuk_website_root" {
  type = string
}

# TODO: pull common vars up from the app modules into here so that they can vary by environment.
