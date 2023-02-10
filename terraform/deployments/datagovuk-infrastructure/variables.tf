variable "cluster_infrastructure_state_bucket" {
  type        = string
  description = "Name of the S3 bucket for the cluster-infrastructure module's Terraform state. Must match the name of the bucket specified in the backend config file."
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
