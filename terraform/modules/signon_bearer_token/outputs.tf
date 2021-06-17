output "secret_arn" {
  value       = aws_secretsmanager_secret.bearer_token.arn
  description = "SecretsManager secret ARN"
}

output "secret_arn_value" {
  value       = "${aws_secretsmanager_secret.bearer_token.arn}:bearer_token::"
  description = "SecretsManager secret ARN with a json-key set"
}

output "token_data" {
  description = "Used for creating the initial secret version during bootstrapping"
  value = {
    application = var.app_name
    permissions = "signin"
    secret_arn  = aws_secretsmanager_secret.bearer_token.arn
  }
}
