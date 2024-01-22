variable "tfvars" {
  type = any
  description = "Variables to add to the variable set"
}

variable "name" {
  type = string
  description = "Name of the created variable set"
}

variable "priority" {
  type    = bool
  default = true
  description = "Should this variable set override others?"
}
