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
  default     = "router"
}

variable "private_subnets" {
  description = "Subnet IDs to use for non-Internet-facing resources."
  type        = list
}

variable "govuk_management_access_security_group" {
  description = "Group used to allow access by management systems"
  type        = string
  default     = "sg-0b873470482f6232d"
}

variable "mesh_name" {
  description = "App Mesh mesh name. For example, 'govuk'"
  type        = string
}

variable "mesh_service_sg_id" {
  type = string
}

variable "service_discovery_namespace_id" {
  type = string
}

variable "service_discovery_namespace_name" {
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
