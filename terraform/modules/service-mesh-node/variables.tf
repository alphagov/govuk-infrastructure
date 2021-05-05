variable "backend_virtual_service_names" {
  type        = list(any)
  description = "Enables the service to communicate with its dependencies (other virtual services) through the service mesh"
}

variable "mesh_name" {
  type = string
}

variable "port" {
  type = number
}

variable "protocol" {
  type = string
}

variable "service_discovery_namespace_id" {
  type = string
}

variable "service_discovery_namespace_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "workspace" {
  type = string
}

variable "additional_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}
