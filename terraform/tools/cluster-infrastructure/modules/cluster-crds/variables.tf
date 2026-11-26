variable "prometheus_operator_crd_version" {
  type        = string
  description = "The prometheus operator version from which to install crds"
  validation {
    condition     = startswith(var.prometheus_operator_crd_version, "v")
    error_message = "The version tag must be prefixed with a 'v'"
  }
}

variable "cilium_crd_version" {
  type        = string
  description = "The cilium version from which to install crds"
  validation {
    condition     = startswith(var.cilium_crd_version, "v")
    error_message = "The version tag must be prefixed with a 'v'"
  }
}



