resource "aws_security_group" "this" {
  for_each = var.neptune_dbs

  name        = "${local.identifier_prefix}${each.value.name}-${var.govuk_environment}-${each.value.engine}-neptune"
  vpc_id      = data.tfe_outputs.vpc.nonsensitive_values.id
  description = "Access to ${each.value.name} Neptune"

  lifecycle { create_before_destroy = true }
}

resource "aws_security_group_rule" "this" {
  for_each = var.neptune_dbs

  security_group_id = aws_security_group.this[each.key].id
  description       = "Access to MySQL database from EKS worker nodes"

  type      = "ingress"
  protocol  = "tcp"
  from_port = each.value.port
  to_port   = each.value.port

  source_security_group_id = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.node_security_group_id
}

