variable "service_name" {
  description = "Service name of the Fargate service, cluster, task etc."
  type        = string
}

variable "container_definitions" {
  description = "List of container definitions, usually provided as a JSON file"
  type        = string
}

variable "desired_count" {
  description = "The desired number of container instances"
  type        = number
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
}

variable "public_service_sg_id" {
  description = "The security group to link the public load balancer to the service"
  type        = string
}

variable "public_tg_arn" {
  description = "The target group to link the public load balancer to the service"
  type        = string
}
