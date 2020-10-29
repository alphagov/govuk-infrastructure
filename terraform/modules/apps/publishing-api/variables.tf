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

variable "image_tag" {
  description = "Container Image Tag"
  type        = string
}

variable "service_name" {
  description = "Service name of the Fargate service, cluster, task etc."
  type        = string
  default     = "publishing-api"
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

variable "govuk_app_domain_internal" {
  type = string
}

variable "govuk_website_root" {
  type = string
}

variable "redis_host" {
  description = "FQDN of the redis cluster for Publishing API"
  type        = string
}

variable "sentry_environment" {
  type = string
}

variable "statsd_host" {
  type = string
}
