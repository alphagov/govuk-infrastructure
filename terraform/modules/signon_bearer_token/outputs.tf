output "secret_arn" {
  value       = aws_secretsmanager_secret.bearer_token.arn
  description = "SecretsManager secret ARN"
}

output "token_data" {
  description = "Used for creating the initial secret version during bootstrapping"
  value = {
    application = var.app_name
    permissions = local.permissions
    secret_arn  = aws_secretsmanager_secret.bearer_token.arn
  }
}
