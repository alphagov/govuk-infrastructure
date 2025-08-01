resource "aws_docdb_cluster_instance" "shared_cluster_instances" {
  count              = var.shared_documentdb_instance_count
  identifier         = "shared-documentdb-${count.index}"
  cluster_identifier = aws_docdb_cluster.shared_cluster.id
  instance_class     = "db.r5.large"
  tags               = aws_docdb_cluster.shared_cluster.tags

  lifecycle {
    ignore_changes = [
      identifier
    ]
  }
}

resource "aws_docdb_subnet_group" "shared_cluster_subnet" {
  name       = "shared-documentdb-${var.govuk_environment}"
  subnet_ids = local.private_subnet_ids
}

resource "aws_docdb_cluster_parameter_group" "shared_parameter_group" {
  family      = "docdb3.6"
  name        = "shared-documentdb-parameter-group"
  description = "Shared DocumentDB cluster parameter group"

  parameter {
    name  = "tls"
    value = "disabled"
  }

  parameter {
    name  = "profiler"
    value = "enabled"
  }

  parameter {
    name  = "profiler_threshold_ms"
    value = "300"
  }
}

resource "random_password" "shared_documentdb_master" {
  length = 100
}

# TODO: Remove me once KMS Key is Imported across all environments.
resource "aws_kms_key" "shared_documentdb_kms_key" {
  description = "Encryption key for Shared DocumentDB"
  key_usage   = "ENCRYPT_DECRYPT"
}

resource "aws_kms_alias" "shared_documentdb_kms_alias" {
  name          = "alias/documentdb/shared-documentdb-kms-key"
  target_key_id = aws_kms_key.shared_documentdb_kms_key.id
}

resource "aws_kms_key_policy" "shared_documentdb_kms_key_policy" {
  key_id = aws_kms_key.shared_documentdb_kms_key.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Delegate permissions to IAM policies",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "Allow access through RDS for all principals in the account that are authorized to use RDS",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "*"
        },
        "Action" : [
          "kms:ReEncrypt*",
          "kms:ListGrants",
          "kms:GenerateDataKey*",
          "kms:Encrypt",
          "kms:DescribeKey",
          "kms:Decrypt",
          "kms:CreateGrant"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "kms:ViaService" : "rds.eu-west-1.amazonaws.com",
            "kms:CallerAccount" : "${data.aws_caller_identity.current.account_id}"
          }
        }
      }
    ]
  })
}

resource "aws_docdb_cluster" "shared_cluster" {
  cluster_identifier              = "shared-documentdb-${var.govuk_environment}${var.shared_documentdb_identifier_suffix}"
  availability_zones              = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  deletion_protection             = true
  db_subnet_group_name            = aws_docdb_subnet_group.shared_cluster_subnet.name
  master_username                 = "master"
  master_password                 = random_password.shared_documentdb_master.result
  storage_encrypted               = true
  backup_retention_period         = var.shared_documentdb_backup_retention_period
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.shared_parameter_group.name
  kms_key_id                      = aws_kms_key.shared_documentdb_kms_key.arn
  vpc_security_group_ids          = [data.tfe_outputs.security.nonsensitive_values.govuk_shared_documentdb_access_sg_id]
  enabled_cloudwatch_logs_exports = ["profiler"]

  lifecycle {
    ignore_changes = [
      cluster_identifier,
      master_password
    ]
  }
}

resource "aws_route53_record" "shared_documentdb" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name    = "shared-documentdb.${var.govuk_environment}.govuk-internal.digital"
  type    = "CNAME"
  ttl     = 300
  records = ["${aws_docdb_cluster.shared_cluster.endpoint}"]
}
