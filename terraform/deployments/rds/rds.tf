locals {
  rds_subnet_ids = compact([for name, id in data.tfe_outputs.vpc.nonsensitive_values.private_subnet_ids : startswith(name, "rds_") ? id : ""])

  is_ephemeral      = startswith(var.govuk_environment, "eph-")
  identifier_prefix = local.is_ephemeral ? "${var.govuk_environment}-" : ""
}

resource "random_string" "database_password" {
  for_each = var.databases

  length  = 32
  special = false
  lifecycle { ignore_changes = [length, special] }
}

# this resource is called `blue-govuk-rds-subnet` in
# integration, staging and production
resource "aws_db_subnet_group" "subnet_group" {
  name       = "${var.govuk_environment}-subnet"
  subnet_ids = local.rds_subnet_ids

  tags = { Name = "blue-govuk-rds-subnet" }

  lifecycle { ignore_changes = [name] }
}

resource "aws_db_parameter_group" "engine_params" {
  for_each = var.databases

  name_prefix = "${var.govuk_environment}-${each.value.name}-${each.value.engine}-"
  family      = each.value.engine_params_family != null ? each.value.engine_params_family : "${each.value.engine}${each.value.engine_version}"

  dynamic "parameter" {
    for_each = each.value.engine_params

    content {
      name         = parameter.key
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  lifecycle { create_before_destroy = true }
}

resource "aws_db_instance" "instance" {
  for_each = var.databases

  // This is purposefully not referencing the resource so that we can create snapshots outside of terraform and use them to launch
  // this instance
  snapshot_identifier = each.value.snapshot_identifier
  engine              = each.value.engine
  engine_version      = each.value.engine_version
  username            = var.database_admin_username
  password            = random_string.database_password[each.key].result
  instance_class      = each.value.instance_class
  identifier = (
    "${local.identifier_prefix}${
      each.value.new_name != null
      ? each.value.new_name
      : each.value.name
    }-${var.govuk_environment}-${each.value.engine}"
  )
  db_subnet_group_name        = aws_db_subnet_group.subnet_group.name
  multi_az                    = var.multi_az
  parameter_group_name        = aws_db_parameter_group.engine_params[each.key].name
  maintenance_window          = each.value.maintenance_window != null ? each.value.maintenance_window : var.maintenance_window
  backup_retention_period     = each.value.backup_retention_period != null ? each.value.backup_retention_period : var.backup_retention_period
  backup_window               = each.value.backup_window != null ? each.value.backup_window : var.backup_window
  copy_tags_to_snapshot       = true
  monitoring_interval         = 60
  monitoring_role_arn         = data.tfe_outputs.logging.nonsensitive_values.rds_enhanced_monitoring_role_arn
  vpc_security_group_ids      = [aws_security_group.rds[each.key].id]
  ca_cert_identifier          = "rds-ca-rsa2048-g1"
  apply_immediately           = each.value.apply_immediately != null ? each.value.apply_immediately : var.govuk_environment != "production"
  allow_major_version_upgrade = each.value.allow_major_version_upgrade
  auto_minor_version_upgrade  = each.value.auto_minor_version_upgrade

  performance_insights_enabled          = each.value.performance_insights_enabled
  performance_insights_retention_period = each.value.performance_insights_enabled ? 7 : 0

  allocated_storage  = each.value.allocated_storage
  iops               = each.value.iops
  storage_throughput = each.value.storage_throughput
  storage_type       = "gp3"

  timeouts {
    create = var.terraform_create_rds_timeout
    delete = var.terraform_delete_rds_timeout
    update = var.terraform_update_rds_timeout
  }

  deletion_protection       = each.value.deletion_protection
  final_snapshot_identifier = "${each.value.new_name != null ? each.value.new_name : each.value.name}-${var.govuk_environment}-${each.value.engine}-final-snapshot"
  skip_final_snapshot       = var.skip_final_snapshot

  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds.arn

  tags = {
    Name    = "govuk-rds-${local.identifier_prefix}${each.value.name}-${var.govuk_environment}-${each.value.engine}",
    project = each.value.project,
  }
}

resource "aws_db_event_subscription" "subscription" {
  name      = "${var.govuk_environment}-rds-event-subscription"
  sns_topic = aws_sns_topic.rds_alerts.arn

  source_type      = "db-instance"
  source_ids       = [for i in aws_db_instance.instance : i.identifier]
  event_categories = ["deletion", "failure", "low storage"]
}

# Alarm if free storage space is below threshold (typically 10 GiB) for 10m.
resource "aws_cloudwatch_metric_alarm" "rds_freestoragespace" {
  for_each = var.databases

  dimensions = { DBInstanceIdentifier = aws_db_instance.instance[each.key].identifier }

  alarm_name          = "${aws_db_instance.instance[each.key].identifier}-rds-freestoragespace"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "10"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Minimum"
  threshold = (
    each.value.allocated_storage * (each.value.storage_alarm_threshold_percentage / 100)
    * 1024 * 1024 * 1024 # allocated_storage is in GB, metric value is in bytes
  )
  alarm_actions     = [aws_sns_topic.rds_alerts.arn]
  ok_actions        = [aws_sns_topic.rds_alerts.arn]
  alarm_description = "Available storage space on ${aws_db_instance.instance[each.key].identifier} RDS is below ${each.value.storage_alarm_threshold_percentage}%."
}

resource "aws_route53_record" "instance_cname" {
  for_each = var.databases

  # Zone is <environment>.govuk-internal.digital.
  zone_id = data.tfe_outputs.root_dns.nonsensitive_values.internal_root_zone_id

  // Right now the names are stuck as the old names. Hopefuilly we can change this soon
  name    = "${local.identifier_prefix}${each.value.name}-${each.value.engine}"
  type    = "CNAME"
  ttl     = 30
  records = [aws_db_instance.instance[each.key].address]
}

resource "aws_db_instance" "replica" {
  for_each = {
    for key, value in var.databases : key => value
    if value.has_read_replica
  }

  instance_class = each.value.instance_class

  identifier                            = "${aws_db_instance.instance[each.key].identifier}-replica"
  replicate_source_db                   = aws_db_instance.instance[each.key].identifier
  performance_insights_enabled          = aws_db_instance.instance[each.key].performance_insights_enabled
  performance_insights_retention_period = aws_db_instance.instance[each.key].performance_insights_retention_period

  engine_version = (
    each.value.replica_engine_version != null
    ? each.value.replica_engine_version
    : aws_db_instance.instance[each.key].engine_version
  )

  apply_immediately          = each.value.replica_apply_immediately != null ? each.value.replica_apply_immediately : var.govuk_environment != "production"
  auto_minor_version_upgrade = aws_db_instance.instance[each.key].auto_minor_version_upgrade
  backup_window              = aws_db_instance.instance[each.key].backup_window
  maintenance_window         = aws_db_instance.instance[each.key].maintenance_window
  multi_az = (
    each.value.replica_multi_az != null
    ? each.value.replica_multi_az
    : var.multi_az
  )

  skip_final_snapshot = true

  tags = {
    Name    = "govuk-rds-${aws_db_instance.instance[each.key].identifier}-replica",
    project = each.value.project,
  }

  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds.arn
}

resource "aws_route53_record" "replica_cname" {
  for_each = {
    for key, value in var.databases : key => value
    if value.has_read_replica
  }

  # Zone is <environment>.govuk-internal.digital.
  zone_id = data.tfe_outputs.root_dns.nonsensitive_values.internal_root_zone_id

  // Right now the names are stuck as the old names.
  // I also hate that I'm setting the name based on which specific DB it is, but
  // in the RDS cleanup we will be doing soon we can sort out these cnames to fix it all
  name = (
    each.key == "publishing_api"
    ? "${local.identifier_prefix}${var.govuk_environment}-${each.value.name}-${each.value.engine}-replica"
    : "${local.identifier_prefix}${each.value.name}-${each.value.engine}-replica"
  )
  type    = "CNAME"
  ttl     = 30
  records = [aws_db_instance.replica[each.key].address]
}

resource "aws_secretsmanager_secret" "database_passwords" {
  name = "${var.govuk_environment}-rds-admin-passwords"
}

resource "aws_secretsmanager_secret_version" "database_passwords" {
  secret_id = aws_secretsmanager_secret.database_passwords.id
  secret_string = jsonencode(
    { for k, v in random_string.database_password : k => v.result }
  )
}
