variable "cluster_name" {
  type        = string
  default     = "govuk"
  description = "Name of the EKS cluster for this environment. Set to the cluster ID for ephemeral clusters."

  validation {
    condition = length(var.cluster_name) >= 1 && length(var.cluster_name) <= 100

    error_message = "Length of cluster_name must be between 1 and 100 characters."
  }
}

