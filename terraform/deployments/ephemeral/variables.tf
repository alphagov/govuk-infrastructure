variable "ephemeral_cluster_id" {
  type = string

  validation {
    condition     = length(var.ephemeral_cluster_id) <= 38
    error_message = "ephemeral_cluster_id must be 38 characters or fewer"
  }

  validation {
    condition     = startswith(var.ephemeral_cluster_id, "eph-")
    error_message = "ephemeral_cluster_id must begin with 'eph-'"
  }
}

variable "organization" {
  type    = string
  default = "govuk"
}
