variable "container_definitions" {
  description = "List of ECS ContainerDefinitions for the task, as maps in HCL/JSON syntax (not strings)."
  type = list(object({
    name        = string
    command     = list(string)
    essential   = bool
    environment = list(object({ name = string, value = string }))
    dependsOn   = list(object({ containerName = string, condition = string }))
    healthCheck = object({
      command     = list(string)
      startPeriod = number
      retries     = number
    })
    image            = string
    linuxParameters  = object({ initProcessEnabled = bool })
    logConfiguration = any
    mountPoints      = list(any),
    portMappings = list(
      object({ containerPort = number, hostPort = number, protocol = string })
    )
    secrets = list(object({ name = string, valueFrom = string }))
    user    = string
  }))
}

variable "cpu" {
  description = "CPU hard limit for the ECS task (total for all containers). 1024 units = 1 vCPU. Only certain pairs of CPU/memory values are valid on Fargate. See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size"
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
  description = "RAM hard limit for the ECS task (total for all containers) in MiB. Only certain pairs of CPU/memory values are valid on Fargate. See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size"
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

variable "volumes" {
  type    = list(object({ name = string }))
  default = []
}
