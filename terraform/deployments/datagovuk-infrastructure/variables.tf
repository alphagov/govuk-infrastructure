variable "govuk_aws_state_bucket" {
  type        = string
  description = "The name of the S3 bucket used for govuk-aws's Terraform state files."
}

variable "ckan_s3_organogram_bucket" {
  type        = string
  description = "Bucket for CKAN organogram data"
}

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
    "https://find.eks.staging.govuk.digital"
  ]
}
