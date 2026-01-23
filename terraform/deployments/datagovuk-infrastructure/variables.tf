variable "ckan_service_account_namespace" {
  type        = string
  description = "Namespace in which the CKAN service account resides"
  default     = "datagovuk"
}

variable "ckan_service_account_name" {
  type        = string
  description = "Name of the service account CKAN will use"
  default     = "ckan"
}

variable "govuk_environment" {
  type        = string
  description = "Acceptable values are test, integration, staging, production"
}

variable "datagovuk_namespace" {
  type        = string
  description = "Name of the namespace to create for ArgoCD to deploy DGU apps into by default."
  default     = "datagovuk"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster to create resources in"
  default     = "govuk"
}

variable "organogram_bucket_cors_origins" {
  type        = list(string)
  description = "List of allowed origins for CORS for organogram bucket"
  default = [
    "https://data.gov.uk",
    "https://www.data.gov.uk",
    "https://staging.data.gov.uk",
    "https://www.staging.data.gov.uk",
    "https://integration.data.gov.uk",
    "https://www.integration.data.gov.uk",
    "https://find.eks.production.govuk.digital",
    "https://find.eks.integration.govuk.digital",
    "https://find.eks.staging.govuk.digital",
    "https://find.eph-aaa113.ephemeral.govuk.digital"
  ]
}

# Variables for rate limiting configuration
variable "find_rate_limit_per_5min" {
  description = "Rate limit for Find app per IP per 5 minutes"
  type        = number
  default     = 100
}

variable "find_rate_limit_warning_per_5min" {
  description = "Warning threshold before blocking (this is for monitoring only)"
  type        = number
  default     = 80
}

variable "waf_log_retention_days" {
  description = "CloudWatch log retention for WAF logs in days"
  type        = number
  default     = 30
}

# Variables for CKAN rate limiting configuration
variable "ckan_rate_limit_per_5min" {
  description = "Rate limit for CKAN app per IP per 5 minutes"
  type        = number
  default     = 1000
}

variable "ckan_rate_limit_warning_per_5min" {
  description = "Warning threshold before blocking (this is for monitoring only)"
  type        = number
  default     = 800
}
