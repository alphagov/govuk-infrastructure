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

