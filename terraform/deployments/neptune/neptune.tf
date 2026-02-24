locals {
  neptune_subnet_ids = compact([for name, id in data.tfe_outputs.vpc.nonsensitive_values.private_subnet_ids : startswith(name, "neptune_") ? id : ""])

  is_ephemeral      = startswith(var.govuk_environment, "eph-")
  identifier_prefix = local.is_ephemeral ? "${var.govuk_environment}-" : ""

  neptune_instances = flatten([
    for db in var.neptune_dbs : [{
      num_of_instances = db.num_of_instances
      instance_class   = db.instance_class
    }]
  ])
}

resource "aws_neptune_cluster" "this" {
  for_each = var.neptune_dbs

  vpc_security_group_ids = [aws_security_group.instance[each.key].id]

  cluster_identifier                    = each.value.cluster_name
  engine                                = each.value.engine
  engine_version                        = each.value.engine_version
  neptune_cluster_parameter_group_name  = each.value.cluster_parameter_group_name
  skip_final_snapshot                   = true
  apply_immediately                     = each.value.apply_immediately != null ? each.value.apply_immediately : var.govuk_environment != "production"
  allow_major_version_upgrade           = each.value.allow_major_version_upgrade
  backup_retention_period               = each.value.backup_retention_period
  copy_tags_to_snapshot                 = true
  deletion_protection                   = each.value.deletion_protection
  enable_cloudwatch_logs_exports        = each.value.enable_cloudwatch_logs_exports
  final_snapshot_identifier             = "${each.value.name}-${var.govuk_environment}-${each.value.engine}-final-snapshot"
  neptune_instance_parameter_group_name = each.value.instance_parameter_group_name
  port                                  = each.value.port
  preferred_backup_window               = each.value.preferred_backup_window
  preferred_maintenance_window          = each.value.preferred_maintenance_window
  snapshot_identifier                   = each.value.snapshot_identifier
  storage_encrypted                     = true
  storage_type                          = each.value.storage_type

  // TODO: supply iam_database_authentication_enabled
  // TODO: supply availability_zones 
  // TODO: supply iam_roles
  // TODO: supply neptune_subnet_group_name
  // TODO: supply kms key arn

  serverless_v2_scaling_configuration {
    // TODO: make this dynamic
    max_capacity = each.value.max_capacity
    min_capacity = each.value.min_capacity
  }

  tags = {
    Name    = "govuk-neptune-${local.identifier_prefix}${each.value.name}-${var.govuk_environment}-${each.value.engine}",
    project = each.value.project,
  }
}

resource "aws_neptune_cluster_instance" "this" {
  for_each = local.neptune_instances

  cluster_identifier = aws_neptune_cluster.this.cluster_identifier
  instance_class     = each.value.instance_class
}
