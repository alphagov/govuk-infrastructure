data "aws_secretsmanager_secret" "github_client_id" {
  name = "grafana_github_client_id"
}

data "aws_secretsmanager_secret" "github_client_secret" {
  name = "grafana_github_client_secret"
}


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
