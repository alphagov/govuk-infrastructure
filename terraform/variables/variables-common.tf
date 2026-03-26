// variables-common.tf
//
// This file contains variable blocks for all common variables.
// If a Terraform root requires any common variables, this file should be symlinked into the root.
// Variables specific to a particular root should be declared in the variables.tf file for that root.

// General

variable "govuk_environment" {
  type        = string
  description = "Name of the environment. Set to the cluster ID for ephemeral clusters."

  validation {
    condition = (
      contains(["production", "staging", "integration", "test"], var.govuk_environment) ||
      startswith(var.govuk_environment, "eph-")
    )

    error_message = "Environment name must be one of production, staging, integration, test, or start with eph- for ephemeral clusters."
  }
}

variable "publishing_service_domain" {
  type        = string
  description = "The publishing domain for this environment."
}

variable "force_destroy" {
  type        = bool
  default     = false
  description = "Whether to force destroy resources when removing Terraform resources."
}

// Networking

variable "vpc_cidr" {
  type        = string
  description = "IPv4 CIDR for VPC"
}

variable "eks_control_plane_subnets" {
  type        = map(object({ az = string, cidr = string }))
  description = "Map of {subnet_name: {az=<az>, cidr=<cidr>}} for the public subnets for the EKS control plane."
}

variable "eks_public_subnets" {
  type        = map(object({ az = string, cidr = string }))
  description = "Map of {subnet_name: {az=<az>, cidr=<cidr>}} for the public subnets for the EKS worker nodes."
}

variable "eks_private_subnets" {
  type        = map(object({ az = string, cidr = string }))
  description = "Map of {subnet_name: {az=<az>, cidr=<cidr>}} for the private subnets for the EKS worker nodes."
}

variable "legacy_private_subnets" {
  type        = map(object({ az = string, cidr = string, nat = bool }))
  description = "Map of {subnet_name: {az=<az>, cidr=<cidr>, nat=<nat>}} for the private subnets for legacy non-EKS resources. nat is a boolean indicating whether the subnet should have a NAT gateway or not."
}

// Kubernetes

variable "cluster_name" {
  type        = string
  default     = "govuk"
  description = "Name of the EKS cluster for this environment. Set to the cluster ID for ephemeral clusters."
}

variable "cluster_log_retention_in_days" {
  type        = number
  description = "Number of days to retain CloudWatch logs for"
}
