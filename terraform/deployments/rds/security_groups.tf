resource "aws_security_group" "rds" {
  for_each = var.databases

  name        = "blue_${each.value.name}_rds_access"
  vpc_id      = data.terraform_remote_state.infra_vpc.outputs.vpc_id
  description = "Access to ${each.value.name} RDS"
  tags        = { Name = "blue_${each.value.name}_rds_access" }
}

resource "aws_security_group_rule" "mysql" {
  for_each          = { for name, data in var.databases : name => data if data.engine == "mysql" }
  security_group_id = aws_security_group.rds[each.key].id
  description       = "Access to MySQL database from EKS worker nodes"

  type      = "ingress"
  protocol  = "tcp"
  from_port = 3306
  to_port   = 3306

  source_security_group_id = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.node_security_group_id
}

resource "aws_security_group_rule" "postgres" {
  for_each          = { for name, data in var.databases : name => data if data.engine == "postgres" }
  security_group_id = aws_security_group.rds[each.key].id
  description       = "Access to PostgreSQL database from EKS worker nodes"

  type      = "ingress"
  protocol  = "tcp"
  from_port = 5432
  to_port   = 5432

  source_security_group_id = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.node_security_group_id

}

import {
  for_each = { for name, data in var.databases : name => data if data.engine == "mysql" }
  to       = aws_security_group_rule.mysql[each.key]
  id       = "${aws_security_group.rds[each.key].id}_ingress_tcp_3306_3306_${data.tfe_outputs.cluster_infrastructure.nonsensitive_values.node_security_group_id}"
}

import {
  for_each = { for name, data in var.databases : name => data if data.engine == "postgres" }
  to       = aws_security_group_rule.postgres[each.key]
  id       = "${aws_security_group.rds[each.key].id}_ingress_tcp_5432_5432_${data.tfe_outputs.cluster_infrastructure.nonsensitive_values.node_security_group_id}"
}
