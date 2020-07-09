variable "service_name" {
  description = "Service name of the Fargate service, cluster, task etc."
  type        = string
}

variable "container_definitions" {
  description = "List of container definitions, usually provided as a JSON file"
  type        = string
}

variable "desired_count" {
  description = "The desired number of container instances"
  type        = number
}
