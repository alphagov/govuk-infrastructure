output "arn" {
  value       = aws_ecs_task_definition.definition.arn
  description = "ARN of the created task definition"
}
