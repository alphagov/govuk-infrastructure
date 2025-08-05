variable "ephemeral_cluster_id" {
  type = string
}

variable "organization" {
  type    = string
  default = "govuk"
}

variable "name" {
  type = string
}

variable "terraform_version" {
  type    = string
  default = "~> 1.11.0"
}

variable "variable_set_id" {
  type = string
}

variable "tfvars" {
  type        = map(any)
  description = "Additional tfvars to set on the workspace"
  default     = {}
}
