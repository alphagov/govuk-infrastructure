locals {
  master_user = "${var.opensearch_domain_name}-masteruser"
}

resource "random_password" "password" {
  length      = 32
  lower       = true
  upper       = true
  numeric     = true
  special     = true
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
}

resource "aws_secretsmanager_secret" "opensearch_passwords" {
  description = "OpenSearch credentials for the ${var.opensearch_domain_name} domain"
  name        = "${var.secrets_manager_prefix}/opensearch"
}

resource "aws_secretsmanager_secret_version" "opensearch_passwords" {
  secret_id = aws_secretsmanager_secret.opensearch_passwords.id
  secret_string = jsonencode({
    url      = "https://${local.service_record_name}"
    username = local.master_user
    password = random_password.password.result
  })
}
