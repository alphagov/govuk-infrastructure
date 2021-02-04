variable "container_definitions" {
  type = list
}

variable "cpu" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "family" {
  type        = string
  description = "Task Definition family. See ECS docs."
}

variable "memory" {
  type = string
}

variable "proxy_configuration" {
  type        = object({ type = string, containerName = string, properties = list(any) })
  description = "Should conform to https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ProxyConfiguration.html"
  default     = null
}

variable "task_role_arn" {
  type = string
}
