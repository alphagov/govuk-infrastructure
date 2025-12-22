output "github_actions_role_arn" {
  value       = aws_iam_role.github_actions_bedrock_ci.arn
  description = "Role ARN for GitHub Actions to assume (use in govuk-chat-evaluation CI)."
}

output "github_actions_oidc_provider_arn" {
  value       = aws_iam_openid_connect_provider.github_actions.arn
  description = "OIDC provider ARN created in the govuk-test account."
}

output "bedrock_model_arns" {
  value       = local.bedrock_model_arns
  description = "Foundation model ARNs that CI role is allowed to invoke."
}
