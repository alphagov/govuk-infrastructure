variable "govuk_aws_state_bucket" {
  type        = string
  description = "The name of the S3 bucket used for govuk-aws's Terraform state files."
}

variable "cluster_infrastructure_state_bucket" {
  type        = string
  description = "Name of the S3 bucket for the cluster-infrastructure module's Terraform state. Must match the name of the bucket specified in the backend config file."
}

variable "grafana_database_min_capacity" {
  type        = number
  description = "Minimum capacity of the Grafana database"
  default     = 2
}

variable "grafana_database_max_capacity" {
  type        = number
  description = "Maximum capacity of the Grafana database"
  default     = 8
}
