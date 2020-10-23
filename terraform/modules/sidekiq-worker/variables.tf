variable "cluster_id" {
  description = "ECS cluster to deploy into."
  type        = string
}

variable "container_definitions" {
  description = "List of container definitions, usually provided as a JSON file"
  type        = string
}

variable "desired_count" {
  description = "The desired number of container instances"
  type        = number
  default     = 1
}
