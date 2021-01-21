output "task_definition_arn" {
  description = "ARNs of the task definition revision"
  value       = aws_ecs_task_definition.smokey.arn
}

output "task_network_config" {
  value       = module.network_config.network_config
  description = "Used by ECS RunTask to run smoke tests."
}
