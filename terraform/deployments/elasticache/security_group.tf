resource "aws_security_group" "cache" {
  description = "EKS to ElastiCache instances (govuk-infrastructure/terraform/deployments/elasticache)"
  name        = "govuk-elasticaches"
  vpc_id      = data.tfe_outputs.vpc.nonsensitive_values.id
  tags = {
    "Name" = "govuk-elasticaches-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "cache" {
  description                  = "Allow inbound requests from EKS nodes"
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
  referenced_security_group_id = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.node_security_group_id
  security_group_id            = aws_security_group.cache.id
  tags = {
    "Name" = "govuk-elasticaches-security-group-ingress"
  }
}

resource "aws_vpc_security_group_egress_rule" "cache" {
  description                  = "Allow outbound requests to EKS nodes"
  ip_protocol                  = -1
  referenced_security_group_id = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.node_security_group_id
  security_group_id            = aws_security_group.cache.id
  tags = {
    "Name" = "govuk-elasticaches-security-group-egress"
  }
}
