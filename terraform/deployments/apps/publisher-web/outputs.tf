output "web_task_definition" {
  value       = module.task_definition.arn
  description = "ARN of the web task definition revision"
}

output "task_network_config" {
  value       = module.network_config.network_config
  description = "Used by ECS RunTask."
}
