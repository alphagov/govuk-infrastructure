variable "container_definitions" {
  description = "List of ECS ContainerDefinitions for the task, as maps in HCL/JSON syntax (not strings)."
  type        = list(any)
}

variable "cpu" {
  description = "CPU hard limit for the ECS task (total for all containers). 1024 units = 1 vCPU. Only certain pairs of CPU/memory values are valid on Fargate. See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html"
  type        = string
}

variable "execution_role_arn" {
  type = string
}

variable "family" {
  type        = string
  description = "Task Definition family. See ECS docs."
}

variable "memory" {
  description = "RAM hard limit for the ECS task (total for all containers) in MiB. Only certain pairs of CPU/memory values are valid on Fargate. See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html"
  type        = string
}

variable "proxy_configuration" {
  type        = object({ type = string, containerName = string, properties = list(any) })
  description = "Should conform to https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ProxyConfiguration.html"
  default     = null
}

variable "task_role_arn" {
  type = string
}
