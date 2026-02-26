locals {
  neptune_subnet_ids = compact([for name, id in data.tfe_outputs.vpc.nonsensitive_values.private_subnet_ids : startswith(name, "neptune_") ? id : ""])
  azs                = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

  is_ephemeral      = startswith(var.govuk_environment, "eph-")
  identifier_prefix = local.is_ephemeral ? "${var.govuk_environment}-" : ""


  neptune_instances = flatten([
    for db in var.neptune_dbs : [
      for i in range(db.instance_count) : {
        key                = "${db.name}-${i}"
        instance_class     = db.instance_class
        apply_immediately  = db.apply_immediately
        cluster_identifier = db.cluster_identifier
        index              = i
      }
    ]
  ])

  neptune_instances_map = {
    for e in local.neptune_instances : e.key => e
  }
}

resource "aws_neptune_subnet_group" "this" {
  name       = "${var.govuk_environment}-subnet"
  subnet_ids = local.neptune_subnet_ids

  lifecycle { ignore_changes = [name] }
}

resource "aws_neptune_cluster_parameter_group" "this" {
  for_each = var.neptune_dbs

  family = each.value.family
  name   = each.value.name

  dynamic "parameter" {
    for_each = each.value.cluster_parameter_group

    content {
      name         = parameter.key
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  lifecycle { create_before_destroy = true }
}

resource "aws_neptune_parameter_group" "this" {
  for_each = var.neptune_dbs

  family = each.value.family
  name   = each.value.name

  dynamic "parameter" {
    for_each = each.value.instance_parameter_group

    content {
      name         = parameter.key
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  lifecycle { create_before_destroy = true }
}

resource "aws_neptune_cluster" "this" {
  for_each = local.neptune_instances_map

  vpc_security_group_ids = [aws_security_group.this[each.key].id]

  cluster_identifier                    = each.value.cluster_name
  engine                                = each.value.engine
  engine_version                        = each.value.engine_version
  neptune_cluster_parameter_group_name  = aws_neptune_cluster_parameter_group.this[each.key].name
  neptune_instance_parameter_group_name = aws_neptune_parameter_group.this[each.key].name
  skip_final_snapshot                   = true
  apply_immediately                     = each.value.apply_immediately != null ? each.value.apply_immediately : var.govuk_environment != "production"
  allow_major_version_upgrade           = each.value.allow_major_version_upgrade
  backup_retention_period               = each.value.backup_retention_period
  copy_tags_to_snapshot                 = true
  deletion_protection                   = each.value.deletion_protection
  enable_cloudwatch_logs_exports        = each.value.enable_cloudwatch_logs_exports
  final_snapshot_identifier             = "${each.value.name}-${var.govuk_environment}-${each.value.engine}-final-snapshot"
  port                                  = each.value.port
  preferred_backup_window               = each.value.preferred_backup_window
  preferred_maintenance_window          = each.value.preferred_maintenance_window
  snapshot_identifier                   = each.value.snapshot_identifier
  storage_encrypted                     = true
  storage_type                          = each.value.storage_type
  kms_key_arn                           = aws_kms_key.neptune.arn
  neptune_subnet_group_name             = aws_neptune_subnet_group.this.name
  availability_zones                    = local.azs
  iam_database_authentication_enabled   = true
  iam_roles                             = each.value.iam_roles

  dynamic "serverless_v2_scaling_configuration" {
    for_each = try(each.value.serverless_config, null)[*]
    content {
      max_capacity = serverless_v2_scaling_configuration.max_capacity
      min_capacity = serverless_v2_scaling_configuration.min_capacity
    }
  }

  tags = {
    Name    = "govuk-neptune-${local.identifier_prefix}${each.value.name}-${var.govuk_environment}-${each.value.engine}",
    project = each.value.project,
  }
}

resource "aws_neptune_cluster_instance" "this" {
  for_each = local.neptune_instances_map

  cluster_identifier = each.value.cluster_identifier
  instance_class     = each.value.instance_class
  apply_immediately  = each.value.apply_immediately != null ? each.value.apply_immediately : var.govuk_environment != "production"
}
