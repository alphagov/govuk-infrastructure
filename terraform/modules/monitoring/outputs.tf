output "grafana_fqdn" {
  value       = "grafana.${local.workspace_external_domain}"
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
