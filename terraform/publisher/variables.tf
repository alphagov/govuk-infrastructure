#
# Variables
#

variable "service_name" {
  description = "Service name of the Fargate service, cluster, task etc."
  type        = string
  default     = "publisher"
}

variable "private_subnets" {
  description = "The subnet ids for govuk_private_a, govuk_private_b, and govuk_private_c"
  type        = list
  default     = ["subnet-6dc4370b", "subnet-463bfd0e", "subnet-bfecd0e4"]
}

variable "public_subnets" {
  description = "The subnet ids for govuk_private_a, govuk_private_b, and govuk_private_c"
  type        = list
  default     = ["subnet-6cc4370a", "subnet-ba30f6f2", "subnet-bfe6dae4"]
}

variable "govuk_management_access_security_group" {
  description = "Group used to allow access by management systems"
  type        = string
  default     = "sg-0b873470482f6232d"
}

variable "container_ingress_port" {
  description = "The port which the container will accept connections on"
  type        = number
  default     = 3000
}

variable "desired_count" {
  description = "The desired number of container instances"
  type        = number
  default     = 1
}
