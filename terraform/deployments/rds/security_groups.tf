resource "aws_security_group" "rds" {
  for_each = var.databases

  name        = "${var.govuk_environment}-${each.value.name}-rds-access"
  vpc_id      = data.tfe_outputs.vpc.nonsensitive_values.id
  description = "Access to ${each.value.name} RDS"

  lifecycle { create_before_destroy = true }
}

resource "aws_security_group_rule" "mysql" {
  for_each = {
    for name, data in var.databases : name => data
    if data.engine == "mysql" && !try(data.isolate, false)
  }
  security_group_id = aws_security_group.rds[each.key].id
  description       = "Access to MySQL database from EKS worker nodes"

  type      = "ingress"
  protocol  = "tcp"
  from_port = 3306
  to_port   = 3306

  source_security_group_id = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.node_security_group_id
}

resource "aws_security_group_rule" "postgres" {
  for_each = {
    for name, data in var.databases : name => data
    if data.engine == "postgres" && !try(data.isolate, false)
  }
  security_group_id = aws_security_group.rds[each.key].id
  description       = "Access to PostgreSQL database from EKS worker nodes"

  type      = "ingress"
  protocol  = "tcp"
  from_port = 5432
  to_port   = 5432

  source_security_group_id = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.node_security_group_id

}

resource "aws_security_group" "normalised_rds" {
  for_each = {
    for db_name, db in var.databases : db_name => db
    if lookup(db, "launch_new_db", false)
  }

  name        = "${local.identifier_prefix}${lookup(each.value, "new_name", each.value.name)}-${var.govuk_environment}-${each.value.engine}-rds-access"
  vpc_id      = data.tfe_outputs.vpc.nonsensitive_values.id
  description = "Access to ${each.value.name} RDS"

  lifecycle { create_before_destroy = true }
}

resource "aws_security_group_rule" "normalised_rds_mysql" {
  for_each = {
    for db_name, db in var.databases : db_name => db
    if lookup(db, "launch_new_db", false) &&
    db.engine == "mysql" &&
    !lookup(db, "isolate_new_db", false)
  }

  security_group_id = aws_security_group.normalised_rds[each.key].id
  description       = "Access to MySQL database from EKS worker nodes"

  type      = "ingress"
  protocol  = "tcp"
  from_port = 3306
  to_port   = 3306

  source_security_group_id = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.node_security_group_id
}

resource "aws_security_group_rule" "normalised_rds_postgres" {
  for_each = {
    for db_name, db in var.databases : db_name => db
    if lookup(db, "launch_new_db", false) &&
    db.engine == "postgres" &&
    !lookup(db, "isolate_new_db", false)
  }

  security_group_id = aws_security_group.normalised_rds[each.key].id
  description       = "Access to PostgreSQL database from EKS worker nodes"

  type      = "ingress"
  protocol  = "tcp"
  from_port = 5432
  to_port   = 5432

  source_security_group_id = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.node_security_group_id

}
