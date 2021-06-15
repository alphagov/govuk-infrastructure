resource "random_password" "grafana_password" {
  length  = 64
  special = false
}

resource "aws_secretsmanager_secret" "grafana_password" {
  name = "grafana_password"
}

resource "aws_secretsmanager_secret_version" "grafana_password" {
  secret_id     = aws_secretsmanager_secret.grafana_password.id
  secret_string = random_password.grafana_password.result
}
