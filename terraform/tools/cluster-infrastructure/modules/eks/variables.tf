variable "environment_name" {
  type        = string
  description = "Name of the cluster being deployed"
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes release version for the cluster, e.g. 1.21"
  default     = "1.36"
}

variable "cluster_creator_principal_arn" {
  type = string
  description = "ARN of the principal which is creating the cluster. This will typically be the Terraform runner role ARN"
}

variable "vpc_config" {
  type = object({
    control_plane_subnet_ids = list(string)
    node_private_subnet_ids  = list(string)
  })
  description = "Config for vpc and vpoc related resources"
}

variable "deletion_protection" {
  type        = bool
  description = "Protection against deletion of the cluster"
  default     = true
}

variable "region" {
  type        = string
  description = "Region to deploy the EKS cluster"
  default     = "eu-west-1"
}

variable "blue_node_group_config" {
  type = object({
    enabled        = bool
    ami_type       = string
    desired_size   = number
    max_size       = number
    min_size       = number
    instance_types = list(string)
    disk_size      = number
  })

  description = "Blue node group config"
}

variable "green_node_group_config" {
  type = object({
    enabled        = bool
    ami_type       = string
    desired_size   = number
    max_size       = number
    min_size       = number
    instance_types = list(string)
    disk_size      = number
  })

  description = "Green node group config"
}

