variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
  default     = "govuk"
}

variable "name" {
  type        = string
  description = "Name of the access entry"
}

variable "access_policy_arn" {
  type        = string
  description = "ARN of the access policy to associate with this role (defaults to AmazonEKSViewPolicy)"
  default     = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
}

variable "access_policy_scope" {
  type        = string
  description = "Scope of the access policy. Either cluster or namespace. access_policy_namespaces is required if scope is namespace"

  validation {
    condition     = contains(["cluster", "namespace"], var.access_policy_scope)
    error_message = "access_policy_scope must be either cluster or namespace"
  }
}

variable "access_policy_namespaces" {
  type        = list(string)
  description = "List of namespaces to add to the access policy"
  default     = []

  validation {
    # if access_policy_scope != cluster, namespaces length must be > 0
    condition     = var.access_policy_scope == "cluster" || length(var.access_policy_namespaces) > 0
    error_message = "access_policy_namespaces must contain at least one namespace if access_policy_scope is namespace"
  }
}

variable "namespace_role_rules" {
  type = list(
    object({
      api_groups = list(string)
      resources  = list(string)
      verbs      = list(string)
    })
  )
  description = "List of rules to apply to kubernetes namespace role resources"
  default     = []
}

variable "cluster_role_rules" {
  type = list(
    object({
      api_groups = list(string)
      resources  = list(string)
      verbs      = list(string)
    })
  )
  description = "List of rules to apply to kubernetes cluster role resources"
  default     = []
}
