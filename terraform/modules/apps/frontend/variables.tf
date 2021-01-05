variable "vpc_id" {
  type = string
}

variable "cluster_id" {
  description = "ECS cluster to deploy into."
  type        = string
}

variable "service_name" {
  description = "Service name of the Fargate service, cluster, task etc."
  type        = string
  default     = "frontend"
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

variable "service_discovery_namespace_id" {
  type = string
}

variable "service_discovery_namespace_name" {
  type = string
}

variable "mesh_name" {
  type = string
}

variable "mesh_service_sg_id" {
  type = string
}

variable "execution_role_arn" {
  description = "For use during bootstrapping"
  type        = string
}

variable "desired_count" {
  description = "Desired count of Application instances"
  type        = number
  default     = 1
}

variable "public_subnets" {
  description = "Subnet IDs to use for Internet-facing resources."
  type        = list
}

variable "public_lb_domain_name" {
  description = "Domain in which to create DNS records for the app's Internet-facing load balancer. For example, staging.govuk.digital"
  type        = string
}
