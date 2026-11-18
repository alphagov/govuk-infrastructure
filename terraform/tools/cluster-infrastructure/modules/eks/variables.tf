variable "environment_name" {
  type        = string
  description = "Name of the cluster being deployed"
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes release version for the cluster, e.g. 1.21"
  default     = "1.36"
}

variable "vpc_config" {
  type = object({
    vpc_id                   = string
    control_plane_subnet_ids = list(string)
    endpoint_public_access   = bool
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

variable "authentication_mode" {
  type        = string
  default     = "API"
  description = "Authentication mode to use for the cluster"
}

variable "node_disk_size" {
  type        = number
  description = "Size in GB of the node default volume"
  default     = 60
}

variable "authentication_mode" {
  type        = string
  default     = "API"
  description = "Authentication mode to use for the cluster"
}

variable "enable_eks_pod_identity_addon" {
  type        = bool
  description = "Whether to enable the EKS Pod Identity Agent addon"
  default     = false
}

variable "enable_network_flow_addon" {
  type        = bool
  description = "Whether to enable the Network Flow Agent addon"
  default     = false
}

variable "enable_arm_workers_blue" {
  type        = bool
  description = "Whether to enable the 'blue' ARM/Graviton-based Managed Node Group"
  default     = false
}

variable "enable_arm_workers_green" {
  type        = bool
  description = "Whether to enable the 'green' ARM/Graviton-based Managed Node Group"
  default     = false

  validation {
    condition     = var.enable_arm_workers_blue || var.enable_arm_workers_green || var.enable_x86_workers
    error_message = "At least one of enable_arm_workers_blue, enable_arm_workers_green, or enable_x86_workers must be true"
  }
}

variable "arm_workers_blue_instance_types" {
  type        = list(string)
  description = "List of ARM-based instance types for the 'blue' managed node group, in order of preference. The second and subsequent preferences are only relevant when using spot instances."
  default     = ["m8g.4xlarge"]
}

variable "arm_workers_green_instance_types" {
  type        = list(string)
  description = "List of ARM-based instance types for the 'green managed node group, in order of preference. The second and subsequent preferences are only relevant when using spot instances."
  default     = ["m8g.4xlarge"]
}

variable "arm_workers_blue_size_desired" {
  type        = number
  description = "Desired capacity of ARM-based 'blue' managed node autoscale group."
  default     = 6
}

variable "arm_workers_green_size_desired" {
  type        = number
  description = "Desired capacity of ARM-based 'green' managed node autoscale group."
  default     = 6
}

variable "arm_workers_blue_size_min" {
  type        = number
  description = "Min capacity of ARM-based 'blue' managed node autoscale group."
  default     = 3
}

variable "arm_workers_green_size_min" {
  type        = number
  description = "Min capacity of ARM-based 'green' managed node autoscale group."
  default     = 3
}

variable "arm_workers_blue_size_max" {
  type        = number
  description = "Max capacity of ARM-based 'blue' managed node autoscale group."
  default     = 12
}

variable "arm_workers_green_size_max" {
  type        = number
  description = "Max capacity of ARM-based 'green' managed node autoscale group."
  default     = 12
}
