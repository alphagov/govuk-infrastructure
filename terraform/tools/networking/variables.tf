
variable "vpc_cidr" {
  type        = string
  description = "IPv4 CIDR for VPC"

  validation {
    condition = cidrhost(var.vpc_cidr, 0) != null

    error_message = "vpc_cidr must be set to a valid CIDR."
  }
}

