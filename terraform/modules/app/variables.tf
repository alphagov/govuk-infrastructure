variable "backend_virtual_service_names" {
  type        = list(any)
  description = "aws_appmesh_virtual_service names called by this app"
}

variable "vpc_id" {
  type = string
}

variable "cluster_id" {
  description = "ECS cluster to deploy into."
  type        = string
}

variable "command" {
  type        = list(any)
  description = "The command to pass to the application container"
  default     = null
}

variable "image_name" {
  type        = string
  description = "Used only for bootstrapping. Provide only the image name, not the tag."
}

variable "image_tag" {
  type        = string
  default     = "latest"
  description = "Used only for bootstrapping. Override default tag latest."
}

variable "registry" {
  type        = string
  description = "registry from which to pull container images"
}

variable "subnets" {
  description = "IDs of the subnets where the ECS task will run."
  type        = list(any)
}

variable "mesh_name" {
  type        = string
  default     = null
  description = "The name of the AWS AppMesh mesh, for example: govuk or govuk-dev-1"
}

variable "service_discovery_namespace_id" {
  type    = string
  default = null
}

variable "service_discovery_namespace_name" {
  type    = string
  default = null
}

variable "service_name" {
  description = "Name to use for the ECS service, task and other resources. Should normally be the name of the app."
  type        = string
}

variable "extra_security_groups" {
  description = "Additional security groups to attach to the app's ECS service/tasks."
  type        = list(any)
  default     = []
}

variable "load_balancers" {
  description = "Optional list of maps {target_group_arn, container_name, container_port} for attaching ALB/NLB target groups to the app's ECS service. See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#load_balancer"
  type        = list(any)
  default     = []
}

variable "container_healthcheck_command" {
  type        = list(string)
  description = "App container liveness healthcheck"
  default     = ["/bin/bash", "-c", "exit 0"]
}

variable "health_check_grace_period_seconds" {
  description = "Meaningful only if load_balancers is non-empty. See healthCheckGracePeriodSeconds in https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service_definition_parameters.html"
  type        = number
  default     = 60
}

variable "desired_count" {
  description = "Desired count of Application instances"
  type        = number
  default     = 1
}

# TODO: Switch the other apps
variable "port" {
  type        = number
  default     = 80
  description = "The port the application listens on. For most apps this can be left as the default (port 80)."
}

variable "environment_variables" {
  type        = map(any)
  default     = {}
  description = <<DESC
  A map of environment variables. For example { RAILS_ENV = "PRODUCTION", ... }
  Do not use this for secret values. Use secrets_from_arns to refer to secrets in SecretsManager instead.
  DESC
}

variable "secrets_from_arns" {
  type        = map(any)
  default     = {}
  description = <<DESC
  A map of secrets to AWS SecretsManager ARNs. For example { OAUTH_SECRET = "arn:aws:secretsmanager:eu-west-1:..." } # pragma: allowlist secret
  DESC
}
variable "log_group" {
  type = string
}
variable "aws_region" {
  type = string
}
variable "cpu" {
  type = string
}
variable "memory" {
  type = string
}
variable "task_role_arn" {
  type = string
}
variable "execution_role_arn" {
  type = string
}
