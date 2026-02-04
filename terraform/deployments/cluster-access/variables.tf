variable "govuk_environment" {
  type        = string
  description = "Acceptable values are test, integration, staging, production"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster to create resources in"
  default     = "govuk"
}

variable "apps_namespace" {
  type        = string
  description = "Name of the namespace to create for ArgoCD to deploy apps into by default."
  default     = "apps"
}

variable "licensify_namespace" {
  type        = string
  description = "Name of the namespace to create for ArgoCD to deploy licensify apps into by default."
  default     = "licensify"
}

variable "datagovuk_namespace" {
  type        = string
  description = "Name of the namespace to create for ArgoCD to deploy DGU apps into by default."
  default     = "datagovuk"
}

