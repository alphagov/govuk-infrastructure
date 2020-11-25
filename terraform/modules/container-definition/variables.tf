variable "command" {
  type = list
}

variable "environment_variables" {
  type = list
}

variable "image_tag" {
  type = string
}

variable "name" {
  type = string
}

variable "secrets" {
  type = list
}

variable "service_name" {
  type = string
}

variable "portMappings" {
  type = list
}
