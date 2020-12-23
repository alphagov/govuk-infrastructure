variable "image_tag" {
  type        = string
  description = "The Docker image tag to be specified in a task definition"
  default     = "latest"
}

variable "assume_role_arn" {
  type        = string
  description = "(optional) AWS IAM role to assume. Uses the role from the environment by default."
  default     = null
}
