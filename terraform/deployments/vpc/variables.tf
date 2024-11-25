variable "govuk_environment" {
  type        = string
  description = "GOV.UK environment where resources are being deployed"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-1"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC IP address range, represented as a CIDR block"
}

variable "traffic_type" {
  type        = string
  description = "The traffic type to capture. Allows ACCEPT, ALL or REJECT"
  default     = "REJECT"
}

variable "cluster_log_retention_in_days" {
  type        = string
  description = "Number of days to retain Cloudwatch logs for"
}

variable "cyber_slunk_s3_bucket_name" {
  type        = string
  description = "Bucket to store logs for ingestion by Splunk"
  default     = "central-pipeline-logging-prod-non-cw"
}

variable "cyber_slunk_aws_account_id" {
  type        = string
  description = "Account ID which holds the Splunk log bucket"
  default     = "885513274347"
}
