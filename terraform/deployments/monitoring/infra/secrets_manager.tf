data "aws_secretsmanager_secret" "splunk_url" {
  name = "SPLUNK_HEC_URL"
}

data "aws_secretsmanager_secret" "splunk_token" {
  name = "SPLUNK_TOKEN"
}

data "aws_secretsmanager_secret" "github_client_id" {
  name = "grafana_github_client_id"
}

data "aws_secretsmanager_secret" "github_client_secret" {
  name = "grafana_github_client_secret"
}
