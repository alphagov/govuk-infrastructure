output "concourse_runner_role_arn" {
  description = "The ARN of the IAM role the Concourse deployment assumes to run Terraform"
  value       = aws_iam_role.concourse_runner.arn
}

output "concourse_oidc_provider_arn" {
  description = "The ARN of the IAM OIDC provider which trusts the Concourse deployment"
  value       = aws_iam_openid_connect_provider.concourse.arn
}
