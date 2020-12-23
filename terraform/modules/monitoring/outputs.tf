output "grafana_fqdn" {
  value       = module.grafana_public_alb.fqdn
  description = "Public Fully Qualified Domain Name for Grafana"
}

output "task_iam_role_arn" {
  value       = aws_iam_role.monitoring_task.arn
  description = "ARN of the Fargate monitoring task IAM role"
}

output "execution_iam_role_arn" {
  value       = aws_iam_role.monitoring_execution.arn
  description = "ARN of the Fargate monitoring execution IAM role"
}
