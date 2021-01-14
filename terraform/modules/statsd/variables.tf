variable "cluster_id" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "internal_domain_name" {
  description = "Domain in which to create DNS records for private resources. For example, test.govuk-internal.digital"
  type        = string
}

variable "mesh_name" {
  type = string
}

variable "private_subnets" {
  description = "Subnet IDs where the statsd ECS service will run."
  type        = list
}

variable "security_groups" {
  description = "Additional security groups to attach to the Statsd ECS Service."
  type        = list
}

variable "service_discovery_namespace_id" {
  type = string
}

variable "service_discovery_namespace_name" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "vpc_id" {
  type = string
}
