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
  default     = "publisher"
}

variable "service_discovery_namespace_id" {
  type = string
}

variable "service_discovery_namespace_name" {
  type = string
}

variable "private_subnets" {
  description = "Subnet IDs to use for non-Internet-facing resources."
  type        = list
}

variable "public_subnets" {
  description = "Subnet IDs to use for Internet-facing resources."
  type        = list
}

variable "public_lb_domain_name" {
  description = "Domain in which to create DNS records for the app's Internet-facing load balancer. For example, staging.govuk.digital"
  type        = string
}

variable "govuk_management_access_sg_id" {
  description = "ID of security group (defined outside this Terraform repo) for access from jumpboxes etc. This SG is added to all ECS instances."
  type        = string
}

variable "mesh_name" {
  description = "App Mesh mesh name. For example, 'govuk'"
  type        = string
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
