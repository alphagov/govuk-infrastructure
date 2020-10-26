variable "cluster_id" {
  description = "ECS cluster to deploy into."
  type        = string
}

variable "container_definitions" {
  description = "List of container definitions, usually provided as a JSON file"
  type        = list
}

variable "desired_count" {
  description = "The desired number of container instances"
  type        = number
  default     = 1
}

variable "private_subnets" {
  description = "The subnet ids for govuk_private_a, govuk_private_b, and govuk_private_c"
  type        = list
  default     = ["subnet-6dc4370b", "subnet-463bfd0e", "subnet-bfecd0e4"]
}

variable "service_discovery_namespace_id" {
  type = string
}

variable "cpu" {
  description = "CPU hard limit for the ECS task (total for all containers). 1024 units = 1 vCPU. Only certain pairs of CPU/memory values are valid on Fargate. See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html"
  type        = number
}

variable "memory" {
  description = "RAM hard limit for the ECS task (total for all containers) in MiB. Only certain pairs of CPU/memory values are valid on Fargate. See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html"
  type        = number
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
  description = "IDs of the subnets where the ECS task will run."
  type        = list
}

variable "mesh_name" {
  type = string
}

variable "service_discovery_namespace_name" {
  type = string
}

variable "task_role_arn" {
  description = "ARN of IAM role for the app's ECS task to talk to other AWS services."
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of IAM role for the ECS container agent and Docker daemon to manage the app container."
  type        = string
}

variable "extra_security_groups" {
  description = "Additional security groups to attach to the app's ECS service/tasks."
  type        = list
  default     = []
}