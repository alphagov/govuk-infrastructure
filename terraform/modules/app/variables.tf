variable "vpc_id" {
  type = string
}

variable "cluster_id" {
  description = "ECS cluster to deploy into."
  type        = string
}

variable "subnets" {
  description = "IDs of the subnets where the ECS task will run."
  type        = list
}

variable "mesh_name" {
  type = string
}

variable "service_discovery_namespace_id" {
  type = string
}

variable "service_discovery_namespace_name" {
  type = string
}

variable "service_name" {
  description = "Name to use for the ECS service, task and other resources. Should normally be the name of the app."
  type        = string
}

variable "custom_container_services" {
  description = "list of services in map format {container_service, port, protocol} that an app container exposes."
  type        = list
  default     = []
}

variable "extra_security_groups" {
  description = "Additional security groups to attach to the app's ECS service/tasks."
  type        = list
  default     = []
}

variable "load_balancers" {
  description = "Optional list of maps {target_group_arn, container_name, container_port} for attaching ALB/NLB target groups to the app's ECS service. See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#load_balancer"
  type        = list
  default     = []
}

variable "health_check_grace_period_seconds" {
  description = "Meaningful only if load_balancers is non-empty. See healthCheckGracePeriodSeconds in https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service_definition_parameters.html"
  type        = number
  default     = 60
}

variable "execution_role_arn" {
  description = "For use during bootstrapping"
  type        = string
}
