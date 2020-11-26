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

variable "govuk_aws_state_bucket" {
  type        = string
  description = "The name of the S3 bucket used for govuk-aws's terraform state files"
}

variable "frontend_desired_count" {
  type    = number
  default = 1
}

variable "draft_frontend_desired_count" {
  type    = number
  default = 1
}

variable "publisher_desired_count" {
  type    = number
  default = 1
}

variable "publishing_api_desired_count" {
  type    = number
  default = 1
}

variable "content_store_desired_count" {
  type    = number
  default = 1
}

variable "draft_content_store_desired_count" {
  type    = number
  default = 1
}

variable "router_desired_count" {
  type    = number
  default = 1
}

variable "draft_router_desired_count" {
  type    = number
  default = 1
}

variable "router_api_desired_count" {
  type    = number
  default = 1
}

variable "draft_router_api_desired_count" {
  type    = number
  default = 1
}

variable "static_desired_count" {
  type    = number
  default = 1
}

variable "draft_static_desired_count" {
  type    = number
  default = 1
}

variable "signon_desired_count" {
  type    = number
  default = 1
}
