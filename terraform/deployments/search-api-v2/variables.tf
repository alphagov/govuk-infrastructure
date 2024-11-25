variable "gcp_project_id" {
  type        = string
  description = "GCP Project ID of the project to create infrastructure in, e.g. search-api-v2-integration"
}

variable "gcp_project_number" {
  type        = string
  description = "GCP Project number"
}

variable "gcp_analytics_project_id" {
  type        = string
  description = "GCP project ID for the project containing BigQuery analytics data"
  default     = "ga4-analytics-352613"
}

variable "gcp_region" {
  type        = string
  description = "GCP region to create non-global infrastructure in, e.g. europe-west2"
  default     = "europe-west2"
}

variable "aws_region" {
  type        = string
  description = "AWS region to create infrastructure in, e.g. eu-west-1"
  default     = "eu-west-1"
}

variable "discovery_engine_api_version" {
  type        = string
  description = "The version of the Discovery Engine API to use, e.g. v1alpha"
  # Defaulting to `v1alpha` as `v1beta` and `v1` APIs don't support datastore creation yet (as of
  # October 2023)
  default = "v1alpha"
}

variable "discovery_engine_location" {
  type        = string
  description = "GCP location to create Discovery Engine Datastore instance in, e.g. global"
  # As of October 2023, we must use `global` as some event-related features are only available
  # there, but this may change before going live
  default = "global"
}
