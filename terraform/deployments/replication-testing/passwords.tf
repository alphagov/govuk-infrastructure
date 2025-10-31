data "aws_kms_key" "secrets_manager" {
  key_id = "alias/aws/secretsmanager"
}

resource "random_password" "content_data_api_source" {
  length  = 32
  special = false
}

resource "random_password" "content_data_api_source_replication" {
  length  = 32
  special = false
}

data "aws_iam_policy_document" "dms_read" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.dms-access-for-endpoint.arn]
    }
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["*"]
  }
}

resource "aws_secretsmanager_secret" "content_data_api_source_replication" {
  name                    = "govuk/jfharden-test/content-data-api-source"
  kms_key_id              = data.aws_kms_key.secrets_manager.key_id
  policy                  = data.aws_iam_policy_document.dms_read.json
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "content_data_api_source_replication" {
  secret_id = aws_secretsmanager_secret.content_data_api_source_replication.id
  secret_string = jsonencode({
    username             = "jfharden_replicator"
    password             = random_password.content_data_api_source_replication.result
    engine               = aws_db_instance.content_data_api_source.engine
    host                 = aws_db_instance.content_data_api_source.address
    port                 = aws_db_instance.content_data_api_source.port
    dbInstanceIdentifier = aws_db_instance.content_data_api_source.identifier
  })
}

resource "random_password" "content_data_api_target" {
  length  = 32
  special = false
}

resource "random_password" "content_data_api_target_replication" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "content_data_api_target_replication" {
  name                    = "govuk/jfharden-test/content-data-api-target"
  kms_key_id              = data.aws_kms_key.secrets_manager.key_id
  policy                  = data.aws_iam_policy_document.dms_read.json
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "content_data_api_target_replication" {
  secret_id = aws_secretsmanager_secret.content_data_api_target_replication.id
  secret_string = jsonencode({
    username             = "jfharden_replicator"
    password             = random_password.content_data_api_target_replication.result
    engine               = aws_db_instance.content_data_api_target.engine
    host                 = aws_db_instance.content_data_api_target.address
    port                 = aws_db_instance.content_data_api_target.port
    dbInstanceIdentifier = aws_db_instance.content_data_api_target.identifier
  })
}

resource "random_password" "whitehall_source" {
  length  = 32
  special = false
}

resource "random_password" "whitehall_source_replication" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "whitehall_source_replication" {
  name                    = "govuk/jfharden-test/whitehall-source"
  kms_key_id              = data.aws_kms_key.secrets_manager.key_id
  policy                  = data.aws_iam_policy_document.dms_read.json
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "whitehall_source_replication" {
  secret_id = aws_secretsmanager_secret.whitehall_source_replication.id
  secret_string = jsonencode({
    username             = "jfharden_replicator"
    password             = random_password.whitehall_source_replication.result
    engine               = aws_db_instance.whitehall_source.engine
    host                 = aws_db_instance.whitehall_source.address
    port                 = aws_db_instance.whitehall_source.port
    dbInstanceIdentifier = aws_db_instance.whitehall_source.identifier
  })
}

resource "random_password" "whitehall_target" {
  length  = 32
  special = false
}

resource "random_password" "whitehall_target_replication" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "whitehall_target_replication" {
  name                    = "govuk/jfharden-test/whitehall-target"
  kms_key_id              = data.aws_kms_key.secrets_manager.key_id
  policy                  = data.aws_iam_policy_document.dms_read.json
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "whitehall_target_replication" {
  secret_id = aws_secretsmanager_secret.whitehall_target_replication.id
  secret_string = jsonencode({
    username             = "jfharden_replicator"
    password             = random_password.whitehall_target_replication.result
    engine               = aws_db_instance.whitehall_target.engine
    host                 = aws_db_instance.whitehall_target.address
    port                 = aws_db_instance.whitehall_target.port
    dbInstanceIdentifier = aws_db_instance.whitehall_target.identifier
  })
}

resource "random_password" "publishing_api" {
  length  = 32
  special = false
}
