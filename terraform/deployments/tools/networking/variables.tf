variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-1"
}

variable "force_destroy" {
  type        = bool
  default     = false
  description = "Whether to force destroy resources when removing Terraform resources."
}

variable "vpc_cidr" {
  type        = string
  description = "IPv4 CIDR for VPC"

  validation {
    condition = cidrhost(var.vpc_cidr, 0) != null

    error_message = "vpc_cidr must be set to a valid CIDR."
  }
}

variable "eks_control_plane_subnets" {
  type        = map(object({ az = string, cidr = string }))
  description = "Map of {subnet_name: {az=<az>, cidr=<cidr>}} for the public subnets for the EKS control plane."

  validation {
    condition = [for subnet in var.eks_control_plane_subnets : cidrhost(subnet.cidr, 0)] != null

    error_message = "Invalid CIDR in eks_control_plane_subnets."
  }
}

variable "eks_public_subnets" {
  type        = map(object({ az = string, cidr = string }))
  description = "Map of {subnet_name: {az=<az>, cidr=<cidr>}} for the public subnets for the EKS worker nodes."

  validation {
    condition = [for subnet in var.eks_public_subnets : cidrhost(subnet.cidr, 0)] != null

    error_message = "Invalid CIDR in eks_public_subnets."
  }
}

variable "eks_private_subnets" {
  type        = map(object({ az = string, cidr = string }))
  description = "Map of {subnet_name: {az=<az>, cidr=<cidr>}} for the private subnets for the EKS worker nodes."

  validation {
    condition = [for subnet in var.eks_private_subnets : cidrhost(subnet.cidr, 0)] != null

    error_message = "Invalid CIDR in eks_private_subnets."
  }
}

variable "cluster_name" {
  type        = string
  default     = "govuk"
  description = "Name of the EKS cluster for this environment. Set to the cluster ID for ephemeral clusters."

  validation {
    condition = length(var.cluster_name) >= 1 && length(var.cluster_name) <= 100

    error_message = "Length of cluster_name must be between 1 and 100 characters."
  }
}
