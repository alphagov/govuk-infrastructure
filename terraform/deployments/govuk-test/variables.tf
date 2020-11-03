#--------------------------------------------------------------
# Network
#--------------------------------------------------------------

variable "mesh_name" {
  type = string
}

variable "mesh_domain" {
  type = string
}

variable "private_subnets" {
  type = list
}

variable "public_lb_domain_name" {
  type = string
}

variable "public_subnets" {
  type = list
}

variable "vpc_id" {
  type = string
}
