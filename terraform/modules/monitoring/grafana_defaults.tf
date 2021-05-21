locals {
  grafana_service_name   = "grafana"
  grafana_container_name = "grafana"

  grafana_environment_variables = {
    GF_SECURITY_ADMIN_USER               = "admin",
    GF_AUTH_GITHUB_ENABLED               = true,
    GF_AUTH_GITHUB_SCOPES                = "user:email,read:org",
    GF_AUTH_GITHUB_AUTH_URL              = "https://github.com/login/oauth/authorize",
    GF_AUTH_GITHUB_TOKEN_URL             = "https://github.com/login/oauth/access_token",
    GF_AUTH_GITHUB_API_URL               = "https://api.github.com/user",
    GF_AUTH_GITHUB_ALLOW_SIGN_UP         = true,
    GF_AUTH_GITHUB_ALLOWED_ORGANIZATIONS = "alphagov",
    GF_AUTH_GITHUB_TEAM_IDS              = "3279243",
    GF_SERVER_DOMAIN                     = "grafana.${local.monitoring_external_domain}",
    GF_SERVER_ROOT_URL                   = "https://%(domain)s",
    GF_SERVER_HTTP_PORT                  = var.grafana_port
  }


  grafana_secrets_from_arns = {
    GF_AUTH_GITHUB_CLIENT_ID     = data.aws_secretsmanager_secret.github_client_id.arn,
    GF_AUTH_GITHUB_CLIENT_SECRET = data.aws_secretsmanager_secret.github_client_secret.arn,
    GF_SECURITY_ADMIN_PASSWORD   = aws_secretsmanager_secret_version.grafana_password.arn,
  }

  grafana_security_groups = [aws_security_group.grafana.id]
}
