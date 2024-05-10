import {
  for_each = { "content_data_api" = data.terraform_remote_state.infra_security_groups.outputs.sg_content-data-api-postgresql-primary_id }
  to = aws_security_group_rule.postgres_from_eks_workers[each.key]
  id = "${each.value}_ingress_tcp_5432_5432_${data.tfe_outputs.cluster_infrastructure.nonsensitive_values.node_security_group_id}"
}
