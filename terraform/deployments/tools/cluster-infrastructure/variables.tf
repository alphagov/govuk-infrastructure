variable "cluster_version" {
  type        = string
  description = "Kubernetes release version for the cluster, e.g. 1.21"
  default     = "1.36"
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

variable "enable_x86_workers" {
  type        = bool
  description = "Whether to enable the x86/AMD64 Managed Node Group"
  default     = true
}

variable "x86_workers_instance_types" {
  type        = list(string)
  description = "List of instance types for the managed node group, in order of preference. The second and subsequent preferences are only relevant when using spot instances."
  default     = ["r7i.large", "r7a.large", "m7i-flex.xlarge", "m6a.xlarge", "m6i.xlarge"]
}

variable "x86_workers_default_capacity_type" {
  type        = string
  description = "Default capacity type for managed node groups: SPOT or ON_DEMAND."
  default     = "ON_DEMAND"
}

variable "x86_workers_size_desired" {
  type        = number
  description = "Desired capacity of managed node autoscale group."
  default     = 3
}

variable "x86_workers_size_min" {
  type        = number
  description = "Min capacity of managed node autoscale group."
  default     = 0
}

variable "x86_workers_size_max" {
  type        = number
  description = "Max capacity of managed node autoscale group."
  default     = 6
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

variable "cluster_name" {
  type        = string
  default     = "govuk"
  description = "Name of the EKS cluster for this environment. Set to the cluster ID for ephemeral clusters."

  validation {
    condition = length(var.cluster_name) >= 1 && length(var.cluster_name) <= 100

    error_message = "Length of cluster_name must be between 1 and 100 characters."
  }
}

variable "cluster_log_retention_in_days" {
  type        = number
  description = "Number of days to retain CloudWatch logs for"
  default     = 731

  validation {
    condition = var.cluster_log_retention_in_days >= 1 && var.cluster_log_retention_in_days <= 3650

    error_message = "cluster_log_retention_in_days must be between 1 day and 10 years."
  }
}
