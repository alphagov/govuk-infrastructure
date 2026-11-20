variable "helm_timeout_seconds" {
  type        = number
  description = "Timeout for helm install/upgrade operations."
  default     = "1200"
}

variable "desired_ha_replicas" {
  type        = number
  description = "Default number of desired replicas for high availability"
  default     = 3
}

variable "ext_dns_enable_service_monitor" {
  type        = bool
  description = "Whether to enable service monitors for external dns"
  default     = true
}

