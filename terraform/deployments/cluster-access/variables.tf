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

variable "job_request_operator_smoke_test_namespace" {
  type        = string
  description = "Name of the namespace to create for ArgoCD to deploy job request operator smoke test resources into by default."
  default     = "job-request-operator-smoke-test"
}