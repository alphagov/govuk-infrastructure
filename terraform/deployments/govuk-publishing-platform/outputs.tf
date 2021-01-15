output "private_subnets" {
  value = data.terraform_remote_state.infra_networking.outputs.private_subnet_ids
}

output "log_group" {
  value = "govuk" # TODO make this workspace aware
}

output "mesh_name" {
  value = var.mesh_name
}

output "mesh_domain" {
  value = var.mesh_domain
}

output "app_domain" {
  value = var.public_lb_domain_name
}

output "app_domain_internal" {
  value = var.internal_domain_name
}

output "govuk_website_root" {
  value = "https://frontend.${var.public_lb_domain_name}" # TODO: Change back to www once router is up
}

output "fargate_execution_iam_role_arn" {
  value = aws_iam_role.execution.arn
}

output "fargate_task_iam_role_arn" {
  value = aws_iam_role.task.arn
}

output "redis_host" {
  value = module.shared_redis_cluster.redis_host
}

output "redis_port" {
  value = module.shared_redis_cluster.redis_port
}

output "frontend_task_definition_cli_input_json" {
  value       = module.frontend_service.task_definition_cli_input_json
  description = <<DESCRIPTION
  Task definition JSON ready to be provided to
  
  ```
  aws ecs register-task-definition --cli-input-json ...
  ```

  The image in the first container definition is left blank, and should be
  overridden.
  DESCRIPTION
}

output "draft_frontend_task_definition_cli_input_json" {
  value       = module.draft_frontend_service.task_definition_cli_input_json
  description = <<DESCRIPTION
  Task definition JSON ready to be provided to
  
  ```
  aws ecs register-task-definition --cli-input-json ...
  ```

  The image in the first container definition is left blank, and should be
  overridden.
  DESCRIPTION
}