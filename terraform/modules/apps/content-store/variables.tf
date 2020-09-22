variable "service_name" {
  description = "Service name of the Fargate service, cluster, task etc."
  type        = string
  default     = "content-store"
}

variable "private_subnets" {
  description = "The subnet ids for govuk_private_a, govuk_private_b, and govuk_private_c"
  type        = list
  default     = ["subnet-6dc4370b", "subnet-463bfd0e", "subnet-bfecd0e4"]
}

variable "govuk_management_access_security_group" {
  description = "Group used to allow access by management systems"
  type        = string
  default     = "sg-0b873470482f6232d"
}

variable "container_ingress_port" {
  description = "The port which the container will accept connections on"
  type        = number
  default     = 80
}

variable "desired_count" {
  description = "The desired number of container instances"
  type        = number
  default     = 1
}

variable "internal_domain_name" {
  description = "The internal root root domain name"
  type        = string
  default     = "test.govuk-internal.digital"
}

variable "appmesh_mesh_govuk_id" {
  type    = string
  default = "govuk"
}

variable "govuk_publishing_platform_namespace_id" {
  type = string
}

variable "govuk_publishing_platform_namespace_name" {
  type = string
}

variable "publishing_api_ingress_security_group" {
  type = string
}
