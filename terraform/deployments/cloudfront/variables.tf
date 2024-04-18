variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "govuk_environment" {
  type        = string
  description = "Name of the environment (AWS account) being deployed to."
}

variable "cloudfront_create" {
  description = "Create Cloudfront resources."
  type        = bool
  default     = false
}

variable "cloudfront_enable" {
  description = "Enable Cloudfront distributions."
  type        = bool
  default     = false
}

variable "origin_www_domain" {
  type = string
}

variable "origin_www_id" {
  type = string
}

variable "origin_assets_domain" {
  type = string
}

variable "origin_assets_id" {
  type = string
}

variable "origin_notify_domain" {
  type = string
}

variable "origin_notify_id" {
  type = string
}

variable "cloudfront_web_acl_default_allow" {
  type        = bool
  description = "Whether the WAF ACL attached to the CloudFront distribution should allow by default."
}

variable "cloudfront_web_acl_allow_gds_ips" {
  type        = bool
  description = "Whether the WAF ACL attached to the CloudFront distribution should restrict access by source IP address."
}

variable "cloudfront_www_distribution_aliases" {
  type        = list(any)
  description = "Additional CNAMEs to create for the www CloudFront distribution."
  default     = []
}

variable "www_certificate_arn" {
  type        = string
  description = "ARN of the TLS cert to use for the www CloudFront distribution."
}

variable "cloudfront_assets_distribution_aliases" {
  type        = list(any)
  description = "Additional CNAMEs for the assets CloudFront distribution."
  default     = []
}

variable "assets_certificate_arn" {
  type        = string
  description = "ARN of the TLS cert to use for the assets CloudFront distribution."
}
