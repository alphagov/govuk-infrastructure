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
  description = "The subnet ids for govuk_private_a, govuk_private_b, and govuk_private_c"
  type        = list
  default     = ["subnet-6dc4370b", "subnet-463bfd0e", "subnet-bfecd0e4"] # TODO hardcoded
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

# TODO: internal_domain_name should be redundant now that internal traffic is via AppMesh.
variable "internal_domain_name" {
  description = "Apex domain name for non-Internet-facing traffic."
  type        = string
  default     = "test.govuk-internal.digital"
}

variable "appmesh_mesh_govuk_id" {
  type    = string
  default = "govuk"
}

variable "service_discovery_namespace_id" {
  type = string
}

variable "service_discovery_namespace_name" {
  type = string
}

variable "publishing_api_ingress_security_group" {
  type = string
}
