#--------------------------------------------------------------
# Network
#--------------------------------------------------------------

variable "mesh_name" {
  type = string
}

variable "mesh_domain" {
  type = string
}

variable "public_lb_domain_name" {
  type = string
}

variable "infra_networking_state_bucket" {
  type = string
}

variable "frontend_desired_count" {
  type    = number
  default = 1
}

variable "content_store_desired_count" {
  type    = number
  default = 1
}

variable "static_desired_count" {
  type    = number
  default = 1
}

variable "frontend_desired_count" {
  type    = number
  default = 1
}
