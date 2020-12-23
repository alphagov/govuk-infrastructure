variable "url" {
  type        = string
  description = "URL at which Grafana can be reached and configured"
}

variable "auth" {
  type        = string
  description = "auth token to access Grafana or username:password string"
}
