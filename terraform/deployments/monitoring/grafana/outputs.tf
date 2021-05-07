output "task_definition_arn" {
  value       = aws_ecs_task_definition.grafana.arn
  description = "ARN of the task definition revision"
}
