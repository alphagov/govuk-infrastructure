variable "security_groups" {
  type        = list(any)
  description = "Security groups to attach to the task"
}

variable "subnets" {
  type        = list(any)
  description = "Private subnets for the task"
}
