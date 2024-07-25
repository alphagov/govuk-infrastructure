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
  subnet_ids = data.terraform_remote_state.infra_networking.outputs.private_subnet_ids
}

import {
  to = aws_docdb_subnet_group.licensify_cluster_subnet
  id = "licensify-documentdb-${var.govuk_environment}"
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

import {
  to = aws_docdb_cluster_parameter_group.licensify_parameter_group
  id = "licensify-parameter-group"
}

resource "aws_docdb_cluster" "licensify_cluster" {
  cluster_identifier              = "licensify-documentdb-${var.govuk_environment}"
  availability_zones              = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  db_subnet_group_name            = aws_docdb_subnet_group.licensify_cluster_subnet.name
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.licensify_parameter_group.name
  master_username                 = "master"
  master_password                 = random_password.licensify_documentdb_master.result
  storage_encrypted               = true
  backup_retention_period         = 1
  kms_key_id                      = data.terraform_remote_state.infra_security.outputs.licensify_documentdb_kms_key_arn
  vpc_security_group_ids          = ["${data.terraform_remote_state.infra_security_groups.outputs.sg_licensify_documentdb_id}"]
  enabled_cloudwatch_logs_exports = ["profiler"]
}

import {
  to = aws_docdb_cluster.licensify_cluster
  id = "licensify-documentdb-${var.govuk_environment}"
}

resource "aws_docdb_cluster_instance" "licensify_cluster_instances" {
  count              = var.licensify_documentdb_instance_count
  identifier         = "licensify-documentdb-${count.index}"
  cluster_identifier = aws_docdb_cluster.licensify_cluster.id
  # TODO: make sure this is the right DB instance size
  instance_class = "db.r5.large"
  tags           = aws_docdb_cluster.licensify_cluster.tags
}

import {
  for_each = range(var.licensify_documentdb_instance_count)
  to       = aws_docdb_cluster_instance.licensify_cluster_instances[each.key]
  id       = "licensify-documentdb-${each.key}"
}
