output "worker_task_definition" {
  value       = module.task_definition.arn
  description = "ARN of the worker task definition revision"
}
