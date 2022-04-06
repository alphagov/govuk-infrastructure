output "grafana_iam_role" {
  description = "IAM role of Grafana"
  value       = module.grafana_iam_role.iam_role_arn
}
