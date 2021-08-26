variable "govuk_aws_state_bucket" {
  type        = string
  description = "The name of the S3 bucket used for govuk-aws's Terraform state files."
}

variable "cluster_log_retention_in_days" {
  type        = number
  description = "Number of days to retain cluster log events in CloudWatch."
}

variable "workers_instance_type" {
  type        = string
  description = "Instance type for the managed node group."
  default     = "m5.xlarge"
}

variable "workers_size_desired" {
  type        = number
  description = "Desired capacity of managed node autoscale group."
  default     = 6
}

variable "workers_size_min" {
  type        = number
  description = "Min capacity of managed node autoscale group."
  default     = 3
}

variable "workers_size_max" {
  type        = number
  description = "Max capacity of managed node autoscale group."
  default     = 9
}
