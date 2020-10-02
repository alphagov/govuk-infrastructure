variable "vpc_id" {
  type = string
}

variable "cluster_id" {
  description = "ECS cluster to deploy into."
  type        = string
}

variable "task_role_arn" {
  description = "ARN of IAM role for app's container (ECS task) to talk to other AWS services."
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of IAM role for the ECS container agent and Docker daemon to manage the app container."
  type        = string
}

variable "service_name" {
  description = "Service name of the Fargate service, cluster, task etc."
  type        = string
  default     = "content-store"
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

variable "container_ingress_port" {
  description = "The port which the container will accept connections on"
  type        = number
  default     = 80
}

variable "desired_count" {
  description = "Number of instances of the ECS task."
  type        = number
  default     = 1
}

variable "mesh_name" {
  type = string
}

variable "service_discovery_namespace_id" {
  type = string
}

variable "service_discovery_namespace_name" {
  type = string
}

variable "govuk_app_domain_external" {
  type = string
}

variable "govuk_website_root" {
  type = string
}

variable "mongodb_host" {
  type = string
}

variable "statsd_host" {
  type = string
}

