output "web_task_definition" {
  value       = module.task_definition.arn
  description = "ARN of the web task definition revision"
}
