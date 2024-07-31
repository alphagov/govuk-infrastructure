resource "aws_docdb_cluster_instance" "shared_cluster_instances" {
  count              = var.shared_documentdb_instance_count
  identifier         = "shared-documentdb-${count.index}"
  cluster_identifier = aws_docdb_cluster.shared_cluster.id
  instance_class     = "db.r5.large"
  tags               = aws_docdb_cluster.shared_cluster.tags
}

import {
  for_each = range(var.shared_documentdb_instance_count)
  to       = aws_docdb_cluster_instance.shared_cluster_instances[each.key]
  id       = "shared-documentdb-${each.key}"
}

resource "aws_docdb_subnet_group" "shared_cluster_subnet" {
  name       = "shared-documentdb-${var.govuk_environment}"
  subnet_ids = data.terraform_remote_state.infra_networking.outputs.private_subnet_ids
}

import {
  to = aws_docdb_subnet_group.shared_cluster_subnet
  id = "shared-documentdb-${var.govuk_environment}"
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

import {
  to = aws_docdb_cluster_parameter_group.shared_parameter_group
  id = "shared-documentdb-parameter-group"
}

resource "random_password" "shared_documentdb_master" {
  length = 100
}

resource "aws_docdb_cluster" "shared_cluster" {
  cluster_identifier              = "shared-documentdb-${var.govuk_environment}"
  availability_zones              = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  db_subnet_group_name            = aws_docdb_subnet_group.shared_cluster_subnet.name
  master_username                 = "master"
  master_password                 = random_password.shared_documentdb_master.result
  storage_encrypted               = true
  backup_retention_period         = var.shared_documentdb_backup_retention_period
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.shared_parameter_group.name
  kms_key_id                      = data.terraform_remote_state.infra_security.outputs.shared_documentdb_kms_key_arn
  vpc_security_group_ids          = ["${data.terraform_remote_state.infra_security_groups.outputs.sg_shared_documentdb_id}"]
  enabled_cloudwatch_logs_exports = ["profiler"]
}

import {
  to = aws_docdb_cluster.shared_cluster
  id = "shared-documentdb-${var.govuk_environment}"
}

resource "aws_route53_record" "shared_documentdb" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name    = "shared-documentdb.${var.govuk_environment}.govuk-internal.digital"
  type    = "CNAME"
  ttl     = 300
  records = ["${aws_docdb_cluster.shared_cluster.endpoint}"]
}

data "aws_route53_zone" "import_zone" {
  name         = "${var.govuk_environment}.govuk-internal.digital."
  private_zone = true
}

import {
  to = aws_route53_record.shared_documentdb
  id = "${data.aws_route53_zone.import_zone.zone_id}_shared-documentdb.${var.govuk_environment}.govuk-internal.digital_CNAME"
}
