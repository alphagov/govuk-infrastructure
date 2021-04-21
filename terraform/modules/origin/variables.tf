variable "name" {
  type        = string
  description = "name of the origin"
}

variable "subdomain" {
  type        = string
  description = "subdomain of origin"
}

variable "extra_aliases" {
  type        = list(any)
  default     = []
  description = "List of additional domains that the CloudFront distribution will accept"
}

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

variable "fronted_apps" {
  type        = map(any)
  description = "map of apps fronted by the CloudFront + ALB. The format {<app_name> = { security_group_id=<security_group_id>,}}"
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

variable "waf_web_acl_arn" {
  type        = string
  description = "arn of the wafv2 web acl to be associated with the CloudFront distribution"
}
