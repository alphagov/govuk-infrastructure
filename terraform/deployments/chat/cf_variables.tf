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

variable "origin_chat_domain" {
  type = string
}

variable "origin_chat_id" {
  type = string
}

variable "cloudfront_chat_distribution_aliases" {
  type        = list(any)
  description = "Additional CNAMEs to create for the www CloudFront distribution."
  default     = []
}

variable "www_certificate_arn" {
  type        = string
  description = "ARN of the TLS cert to use for the www CloudFront distribution."
}

