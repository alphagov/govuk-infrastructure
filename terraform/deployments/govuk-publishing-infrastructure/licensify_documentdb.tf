data "terraform_remote_state" "infra_security" {
  backend = "s3"

  config = {
    bucket = "${var.govuk_aws_state_bucket}"
    key    = "govuk/infra-security.tfstate"
    region = "eu-west-1"
  }
}

resource "random_password" "licensify_documentdb_master" {
  length = 100
}

resource "aws_docdb_subnet_group" "licensify_cluster_subnet" {
  name       = "licensify-documentdb-${var.govuk_environment}"
  subnet_ids = local.private_subnet_ids
}

resource "aws_docdb_cluster_parameter_group" "licensify_parameter_group" {
  family      = "docdb3.6"
  name        = "licensify-parameter-group"
  description = "Licensify DocumentDB cluster parameter group"

  # Licensify doesn't support connecting to MongoDB via TLS
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
    value = 300
  }
}

resource "aws_kms_key" "licensify_documentdb_kms_key" {
  description = "Encryption key for Licensify DocumentDB"
  key_usage   = "ENCRYPT_DECRYPT"
}

resource "aws_kms_alias" "licensify_documentdb_kms_alias" {
  name          = "alias/documentdb/licensify-documentdb-kms-key"
  target_key_id = aws_kms_key.licensify_documentdb_kms_key.id
}

resource "aws_kms_key_policy" "licensify_documentdb_kms_key_policy" {
  key_id = aws_kms_key.licensify_documentdb_kms_key.id

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

locals {
  list_licensify_docdb_sg_ids = [
    data.tfe_outputs.security.nonsensitive_values.licensify_documentdb_access_sg_id
  ]
}

resource "aws_docdb_cluster" "licensify_cluster" {
  cluster_identifier              = "licensify-documentdb-${var.govuk_environment}"
  availability_zones              = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  db_subnet_group_name            = aws_docdb_subnet_group.licensify_cluster_subnet.name
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.licensify_parameter_group.name
  master_username                 = "master"
  master_password                 = random_password.licensify_documentdb_master.result
  storage_encrypted               = true
  kms_key_id                      = aws_kms_key.licensify_documentdb_kms_key.arn
  vpc_security_group_ids          = local.list_licensify_docdb_sg_ids
  enabled_cloudwatch_logs_exports = ["profiler"]
  backup_retention_period         = var.licensify_backup_retention_period
}

resource "aws_docdb_cluster_instance" "licensify_cluster_instances" {
  count              = var.licensify_documentdb_instance_count
  identifier         = "licensify-documentdb-${count.index}"
  cluster_identifier = aws_docdb_cluster.licensify_cluster.id
  # TODO: make sure this is the right DB instance size
  instance_class = "db.r5.large"
  tags           = aws_docdb_cluster.licensify_cluster.tags
}
