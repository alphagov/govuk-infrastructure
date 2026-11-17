variable "govuk_account" {
  type        = string
  description = "Name of the account being deployed to"
  default     = "tools"
}

variable "environment_name" {
  type = string
  description = "Name of the environment being deployed"
}

variable "vpc_cidr" {
  type        = string
  description = "IPv4 CIDR for VPC"

  default = "10.14.0.0/16"

  validation {
    condition = cidrhost(var.vpc_cidr, 0) != null

    error_message = "vpc_cidr must be set to a valid CIDR."
  }
}