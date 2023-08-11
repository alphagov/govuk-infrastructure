variable "sentry_auth_token" {
  type        = string
  description = "The Sentry API token used for authentication."
  sensitive   = true
}
