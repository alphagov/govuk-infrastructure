variable "image_tag" {
  description = "Container Image Tag"
  type        = string
}

variable "mesh_name" {
  type = string
}

variable "signon_db_url" {
  description = "URL for the signon database (defined outside this Terraform repo)."
  type        = string
}

variable "signon_test_db_url" {
  description = "URL for the signon_test database (defined outside this Terraform repo)."
  type        = string
}

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "sentry_environment" {
  type = string
}

variable "assume_role_arn" {
  type        = string
  description = "(optional) AWS IAM role to assume. Uses the role from the environment by default."
  default     = null
}
