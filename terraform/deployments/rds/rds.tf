locals {
  rds_subnet_ids = compact([for name, id in data.tfe_outputs.vpc.nonsensitive_values.private_subnet_ids : startswith(name, "rds_") ? id : ""])
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
  family      = merge({ engine_params_family = "${each.value.engine}${each.value.engine_version}" }, each.value)["engine_params_family"]

  dynamic "parameter" {
    for_each = each.value.engine_params

    content {
      name         = parameter.key
      value        = parameter.value.value
      apply_method = merge({ apply_method = "immediate" }, parameter.value)["apply_method"]
    }
  }

  lifecycle { create_before_destroy = true }

}

# this resource has no `var.govuk_environment` prefix in
# integration, staging and production
resource "aws_db_instance" "instance" {
  for_each = var.databases

  engine                  = each.value.engine
  engine_version          = each.value.engine_version
  username                = var.database_admin_username
  password                = random_string.database_password[each.key].result
  instance_class          = each.value.instance_class
  identifier              = "${var.govuk_environment}-${each.value.name}-${each.value.engine}"
  db_subnet_group_name    = aws_db_subnet_group.subnet_group.name
  multi_az                = var.multi_az
  parameter_group_name    = aws_db_parameter_group.engine_params[each.key].name
  maintenance_window      = lookup(each.value, "maintenance_window", var.maintenance_window)
  backup_retention_period = lookup(each.value, "backup_retention_period", var.backup_retention_period)
  backup_window           = var.backup_window
  copy_tags_to_snapshot   = true
  monitoring_interval     = 60
  monitoring_role_arn     = data.tfe_outputs.logging.nonsensitive_values.rds_enhanced_monitoring_role_arn
  vpc_security_group_ids  = [aws_security_group.rds[each.key].id]
  ca_cert_identifier      = "rds-ca-rsa2048-g1"
  apply_immediately       = true # var.govuk_environment != "production"

  performance_insights_enabled          = each.value.performance_insights_enabled
  performance_insights_retention_period = each.value.performance_insights_enabled ? 7 : 0

  allocated_storage  = each.value.allocated_storage
  iops               = try(each.value.iops, null)
  storage_throughput = try(each.value.storage_throughput, null)
  storage_type       = "gp3"

  timeouts {
    create = var.terraform_create_rds_timeout
    delete = var.terraform_delete_rds_timeout
    update = var.terraform_update_rds_timeout
  }

  deletion_protection       = var.govuk_environment == "production"
  final_snapshot_identifier = "${each.value.name}-final-snapshot"
  skip_final_snapshot       = var.skip_final_snapshot

  tags = { Name = "govuk-rds-${each.value.name}-${each.value.engine}", project = lookup(each.value, "project", "GOV.UK - Other") }

  lifecycle { ignore_changes = [identifier] }
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
  for_each   = var.databases
  dimensions = { DBInstanceIdentifier = aws_db_instance.instance[each.key].identifier }

  alarm_name          = "${aws_db_instance.instance[each.key].identifier}-rds-freestoragespace"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "10"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Minimum"
  threshold = (
    each.value.allocated_storage * (tonumber(lookup(each.value, "storage_alarm_threshold_percentage", 10)) / 100)
    * 1024 * 1024 * 1024 # allocated_storage is in GB, metric value is in bytes
  )
  alarm_actions     = [aws_sns_topic.rds_alerts.arn]
  alarm_description = "Available storage space on ${aws_db_instance.instance[each.key].identifier} RDS is below ${lookup(each.value, "storage_alarm_threshold_percentage", 10)}%."
}

resource "aws_route53_record" "instance_cname" {
  for_each = var.databases

  # Zone is <environment>.govuk-internal.digital.
  zone_id = data.tfe_outputs.root_dns.nonsensitive_values.internal_root_zone_id
  name    = aws_db_instance.instance[each.key].identifier
  type    = "CNAME"
  ttl     = 300
  records = [aws_db_instance.instance[each.key].address]
}

resource "aws_db_instance" "replica" {
  for_each = {
    for key, value in var.databases : key => value
    if lookup(value, "has_read_replica", false)
  }

  instance_class      = each.value.instance_class
  identifier          = "${var.govuk_environment}-${each.value.name}-${each.value.engine}-replica"
  replicate_source_db = aws_db_instance.instance[each.key].identifier

  skip_final_snapshot = true

  tags = { Name = "govuk-rds-${each.value.name}-${each.value.engine}-replica", project = lookup(each.value, "project", "GOV.UK - Other") }

  lifecycle { ignore_changes = [identifier] }
}

resource "aws_route53_record" "replica_cname" {
  for_each = {
    for key, value in var.databases : key => value
    if lookup(value, "has_read_replica", false) == true
  }

  # Zone is <environment>.govuk-internal.digital.
  zone_id = data.tfe_outputs.root_dns.nonsensitive_values.internal_root_zone_id
  name    = aws_db_instance.replica[each.key].identifier
  type    = "CNAME"
  ttl     = 300
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
