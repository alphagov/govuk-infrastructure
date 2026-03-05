variable "ephemeral_cluster_id" {
  type = string
}

variable "organization" {
  type    = string
  default = "govuk"
}

variable "git_branch" {
  type        = string
  description = "The name of the Git branch on which the ephemeral cluster should be based. Defaults to main."
  default     = "main"
}
