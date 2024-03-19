resource "random_string" "database_password" {
  for_each = var.databases

  length = 32
  lower  = true
}

resource "aws_db_subnet_group" "subnet_group" {
  name       = "${var.stackname}-govuk-rds-subnet"
  subnet_ids = data.terraform_remote_state.infra_networking.outputs.private_subnet_rds_ids

  tags = { Name = "${var.stackname}-govuk-rds-subnet" }
}

resource "aws_db_parameter_group" "engine_params" {
  for_each = var.databases

  name_prefix = "${each.value.name}-${each.value.engine}-"
  family      = merge({ engine_params_family = "${each.value.engine}${each.value.engine_version}" }, each.value)["engine_params_family"]

  dynamic "parameter" {
    for_each = each.value.engine_params

    content {
      name         = parameter.key
      value        = parameter.value.value
      apply_method = merge({ apply_method = "immediate" }, parameter.value)["apply_method"]
    }
  }
}

resource "aws_db_instance" "instance" {
  for_each = var.databases

  engine                  = each.value.engine
  engine_version          = each.value.engine_version
  username                = var.database_admin_username
  password                = random_string.database_password[each.key].result
  allocated_storage       = each.value.allocated_storage
  instance_class          = each.value.instance_class
  identifier              = "${each.value.name}-${each.value.engine}"
  storage_type            = "gp3"
  db_subnet_group_name    = aws_db_subnet_group.subnet_group.name
  multi_az                = var.multi_az
  parameter_group_name    = aws_db_parameter_group.engine_params[each.key].name
  maintenance_window      = var.maintenance_window
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  copy_tags_to_snapshot   = true
  monitoring_interval     = 60
  monitoring_role_arn     = data.terraform_remote_state.infra_monitoring.outputs.rds_enhanced_monitoring_role_arn
  vpc_security_group_ids  = [aws_security_group.rds[each.key].id]
  ca_cert_identifier      = "rds-ca-rsa2048-g1"
  apply_immediately       = var.govuk_environment != "production"

  performance_insights_enabled          = each.value.performance_insights_enabled
  performance_insights_retention_period = each.value.performance_insights_enabled ? 7 : 0

  timeouts {
    create = var.terraform_create_rds_timeout
    delete = var.terraform_delete_rds_timeout
    update = var.terraform_update_rds_timeout
  }

  deletion_protection       = var.govuk_environment == "production"
  final_snapshot_identifier = "${each.value.name}-final-snapshot"
  skip_final_snapshot       = var.skip_final_snapshot

  tags = { Name = "${var.stackname}-govuk-rds-${each.value.name}-${each.value.engine}" }
}

resource "aws_db_event_subscription" "subscription" {
  name      = "govuk-rds-event-subscription"
  sns_topic = data.terraform_remote_state.infra_monitoring.outputs.sns_topic_rds_events_arn

  source_type      = "db-instance"
  source_ids       = [for i in aws_db_instance.instance : i.identifier]
  event_categories = ["availability", "deletion", "failure", "low storage"]
}

# Alarm if free storage space is below threshold (typically 10 GiB) for 10m.
resource "aws_cloudwatch_metric_alarm" "rds_freestoragespace" {
  for_each   = var.databases
  dimensions = { DBInstanceIdentifier = aws_db_instance.instance[each.key].id }

  alarm_name          = "${each.value.name}-rds-freestoragespace"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "10"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Minimum"
  threshold           = each.value.freestoragespace_threshold
  alarm_actions       = [data.terraform_remote_state.infra_monitoring.outputs.sns_topic_cloudwatch_alarms_arn]
  alarm_description   = "Available storage space on ${each.value.name} RDS is too low."
}

resource "aws_route53_record" "instance_cname" {
  for_each = var.databases

  # Zone is <environment>.govuk-internal.digital.
  zone_id = data.terraform_remote_state.infra_root_dns_zones.outputs.internal_root_zone_id
  name    = "${each.value.name}-${each.value.engine}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_db_instance.instance[each.key].address]
}
