output "app_data" {
  description = "Used for creating the OAuth app in Signon during bootstrapping"
  value = {
    description  = var.description,
    home_uri     = var.home_uri,
    id_arn       = aws_secretsmanager_secret.oauth_id.arn,
    name         = var.app_name,
    permissions  = var.permissions
    redirect_uri = "${var.home_uri}${var.redirect_path}",
    secret_arn   = aws_secretsmanager_secret.oauth_secret.arn,
  }
}

output "id_arn" {
  value = aws_secretsmanager_secret.oauth_id.arn
}

output "secret_arn" {
  value = aws_secretsmanager_secret.oauth_secret.arn
}
