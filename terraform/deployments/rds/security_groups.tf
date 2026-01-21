resource "aws_security_group" "instance" {
  for_each = var.databases

  name        = "${local.identifier_prefix}${each.value.name}-${var.govuk_environment}-${each.value.engine}-rds"
  vpc_id      = data.tfe_outputs.vpc.nonsensitive_values.id
  description = "Access to ${each.value.name} RDS"

  lifecycle { create_before_destroy = true }
}

moved {
  from = aws_security_group.instance["imminence"]
  to   = aws_security_group.instance["places_manager"]
}

resource "aws_security_group_rule" "mysql" {
  for_each = {
    for db_name, db in var.databases : db_name => db
    if db.engine == "mysql"
  }

  security_group_id = aws_security_group.instance[each.key].id
  description       = "Access to MySQL database from EKS worker nodes"

  type      = "ingress"
  protocol  = "tcp"
  from_port = 3306
  to_port   = 3306

  source_security_group_id = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.node_security_group_id
}

resource "aws_security_group_rule" "postgres" {
  for_each = {
    for db_name, db in var.databases : db_name => db
    if db.engine == "postgres"
  }

  security_group_id = aws_security_group.instance[each.key].id
  description       = "Access to PostgreSQL database from EKS worker nodes"

  type      = "ingress"
  protocol  = "tcp"
  from_port = 5432
  to_port   = 5432

  source_security_group_id = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.node_security_group_id
}

moved {
  from = aws_security_group_rule.postgres["imminence"]
  to   = aws_security_group_rule.postgres["places_manager"]
}
