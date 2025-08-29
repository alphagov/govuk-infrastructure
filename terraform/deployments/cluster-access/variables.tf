variable "govuk_environment" {
  type        = string
  description = "Acceptable values are test, integration, staging, production"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster to create resources in"
  default     = "govuk"
}
