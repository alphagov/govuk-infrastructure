variable "aws_region" {
  type        = string
  description = "E.g. eu-west-1"
}

variable "command" {
  type        = list(any)
  description = "The command to pass to the container"
  default     = null
}

variable "environment_variables" {
  type        = map(any)
  default     = {}
  description = <<DESC
  A map of environment variables. For example { RAILS_ENV = "PRODUCTION", ... }
  Do not use this for secret values. Use secrets_from_arns to refer to secrets in SecretsManager instead.
DESC
}

variable "dependsOn" {
  type        = list(any)
  default     = []
  description = "See ECS Task Definition spec for dependsOn"
}

variable "health_check" {
  type        = string
  default     = "exit 0"
  description = "Command checks the container is ready to receive requests."
}

variable "image" {
  type    = string
  default = null
}

variable "registry_creds" {
  type        = string
  default     = null
  description = "ARN of Secrets Manager secret for container registry login, if authentication is needed to pull the image."
}

variable "log_group" {
  type = string
}

variable "log_stream_prefix" {
  type        = string
  description = "Set log_stream_prefix to an ECS Service name, if applicable. A prefix makes it easier to associate a log with a service."
}

variable "name" {
  type        = string
  default     = "app"
  description = "Name for the container. Must match the associated ALB."
}

variable "ports" {
  type        = list(any)
  default     = [80]
  description = "The ports the application listens on. For most apps this can be left as the default (port 80)."
}

variable "secrets_from_arns" {
  type        = map(any)
  default     = {}
  description = <<DESC
  A map of secrets to AWS SecretsManager ARNs. For example { OAUTH_SECRET = "arn:aws:secretsmanager:eu-west-1:..." } # pragma: allowlist secret
DESC
}

variable "user" {
  type    = string
  default = null
}
