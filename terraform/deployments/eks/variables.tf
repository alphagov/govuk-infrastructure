variable "assume_role_arn" {
  type        = string
  description = "(optional) AWS IAM role to assume. Uses the role from the environment by default."
  default     = null
}

variable "govuk_aws_state_bucket" {
  type        = string
  description = "The name of the S3 bucket used for govuk-aws's terraform state files"
  # TODO: this probably should not have a default
  default = "govuk-terraform-steppingstone-test"
}

variable "workers_instance_type" {
  type        = string
  description = "Instance type for the managed node group."
  default     = "m5.xlarge"
}

variable "workers_size_desired" {
  type        = number
  description = "Desired capacity of managed node autoscale group."
  default     = 3
}

variable "workers_size_min" {
  type        = number
  description = "Min capacity of managed node autoscale group."
  default     = 3
}

variable "workers_size_max" {
  type        = number
  description = "Max capacity of managed node autoscale group."
  default     = 3
}
