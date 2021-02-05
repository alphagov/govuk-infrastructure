variable "aws_region" {
  type        = string
  description = "E.g. eu-west-1"
}

variable "command" {
  type        = list
  description = "The command to pass to the container"
  default     = null
}

variable "environment_variables" {
  type        = map
  default     = {}
  description = <<DESC
  A map of environment variables. For example { RAILS_ENV = "PRODUCTION", ... }
  Do not use this for secret values. Use secrets_from_arns to refer to secrets in SecretsManager instead.
DESC
}

variable "dependsOn" {
  type        = list
  default     = []
  description = "See ECS Task Definition spec for dependsOn"
}

variable "image" {
  type    = string
  default = null
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
  type        = list
  default     = [80]
  description = "The ports the application listens on. For most apps this can be left as the default (port 80)."
}

variable "secrets_from_arns" {
  type        = map
  default     = {}
  description = <<DESC
  A map of secrets to AWS SecretsManager ARNs. For example { OAUTH_SECRET = "arn:aws:secretsmanager:eu-west-1:..." } # pragma: allowlist secret
DESC
}

variable "user" {
  type    = string
  default = null
}
