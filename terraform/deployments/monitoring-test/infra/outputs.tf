output "grafana_fqdn" {
  value       = module.monitoring.grafana_fqdn
  description = "Public Fully Qualified Domain Name for Grafana"
}

output "task_iam_role_arn" {
  value       = module.monitoring.task_iam_role_arn
  description = "ARN of the Fargate monitoring task IAM role"
}

output "execution_iam_role_arn" {
  value       = module.monitoring.execution_iam_role_arn
  description = "ARN of the Fargate monitoring execution IAM role"
}
