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
