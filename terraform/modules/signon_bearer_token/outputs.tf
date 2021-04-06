output "secret_arn" {
  value       = aws_secretsmanager_secret.bearer_token.arn
  description = "SecretsManager secret ARN"
}
