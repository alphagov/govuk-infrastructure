variable "security_groups" {
  type        = list
  description = "Security groups to attach to the task"
}

variable "subnets" {
  type        = list
  description = "Private subnets for the task"
}
