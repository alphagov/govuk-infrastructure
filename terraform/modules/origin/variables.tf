variable "external_app_domain" {
  type        = string
  description = "e.g. ecs.test.govuk.digital. Domain in which to create DNS records for the app's Internet-facing load balancer."
}

variable "load_balancer_certificate_arn" {
  type = string
}

variable "cloudfront_certificate_arn" {
  type = string
}

variable "is_live" {
  description = "Determines whether the origin is a live or a draft one"
  type        = bool
  default     = true
}

variable "apps_security_config_list" {
  type        = map(any)
  description = "map in the format {<app_name> = { security_group_id=<security_group_id>, target_port=<target_port>}}"
}

variable "external_cidrs_list" {
  type    = list(any)
  default = ["0.0.0.0/0"]
}

variable "publishing_service_domain" {
  type        = string
  description = "e.g. test.publishing.service.gov.uk"
}

variable "public_subnets" {
  type = list(any)
}

variable "vpc_id" {
  type = string
}

variable "public_zone_id" {
  type = string
}

variable "workspace" {
  type = string
}

variable "is_default_workspace" {
  type = bool
}

variable "rails_assets_s3_regional_domain_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "assume_role_arn" {
  type        = string
  description = "(optional) AWS IAM role to assume. Uses the role from the environment by default."
  default     = null
}
