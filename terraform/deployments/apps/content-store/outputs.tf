output "draft_task_definition" {
  description = "ARNs of the draft task definition revision"
  value       = aws_ecs_task_definition.draft.arn
}

output "live_task_definition" {
  description = "ARNs of the live task definition revision"
  value       = aws_ecs_task_definition.live.arn
}
