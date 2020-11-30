variable "mesh_name" {
  type = string
}

variable "service_name" {
  description = "Service name of the Fargate service, cluster, task etc."
  type        = string
}

variable "container_definitions" {
  description = "List of ECS ContainerDefinitions for the app, as maps in HCL/JSON syntax (not strings). The module adds the Envoy sidecar to this list."
  type        = list
}

variable "cpu" {
  description = "CPU hard limit for the ECS task (total for all containers). 1024 units = 1 vCPU. Only certain pairs of CPU/memory values are valid on Fargate. See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html"
  type        = number
}

variable "memory" {
  description = "RAM hard limit for the ECS task (total for all containers) in MiB. Only certain pairs of CPU/memory values are valid on Fargate. See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html"
  type        = number
}

variable "container_ingress_ports" {
  description = "Comma-separated string listing ports on which the app container accepts connections."
  type        = string
  default     = "80"
}

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}
