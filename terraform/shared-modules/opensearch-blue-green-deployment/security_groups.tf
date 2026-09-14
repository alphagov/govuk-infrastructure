resource "aws_security_group" "opensearch" {
  name        = "opensearch-${var.opensearch_domain_name}"
  vpc_id      = data.tfe_outputs.vpc.nonsensitive_values.id
  description = "Allow access to OpenSearch from EKS nodes"
}

resource "aws_security_group_rule" "opensearch_cluster_from_eks" {
  description              = "OpenSearch accepts HTTPS requests from EKS nodes"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.opensearch.id
  source_security_group_id = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.node_security_group_id
}

resource "aws_security_group_rule" "opensearch_cluster_from_self" {
  description       = "OpenSearch accepts OpenSearch requests from itself"
  type              = "ingress"
  from_port         = 9200
  to_port           = 9200
  protocol          = "tcp"
  security_group_id = aws_security_group.opensearch.id
  self              = true
}

resource "aws_security_group_rule" "opensearch_cluster_from_self_https" {
  description       = "OpenSearch accepts OpenSearch requests from itself"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.opensearch.id
  self              = true
}
