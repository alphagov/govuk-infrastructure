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

resource "aws_security_group_rule" "opensearch_cluster_from_old_elasticsearch_cluster" {
  for_each = var.override_security_group_ids_for_green_cluster == null ? [] : toset(var.override_security_group_ids_for_green_cluster)

  description              = "OpenSearch accepts OpenSearch requests from old Elasticsearch cluster"
  type                     = "ingress"
  from_port                = 9200
  to_port                  = 9200
  protocol                 = "tcp"
  security_group_id        = aws_security_group.opensearch.id
  source_security_group_id = each.value
}

resource "aws_security_group_rule" "old_elasticsearch_cluster_from_opensearch_cluster" {
  for_each = var.override_security_group_ids_for_green_cluster == null ? [] : toset(var.override_security_group_ids_for_green_cluster)

  description              = "Old Elasticsearch cluster accepts Elasticsearch requests from OpenSearch"
  type                     = "ingress"
  from_port                = 9200
  to_port                  = 9200
  protocol                 = "tcp"
  security_group_id        = each.value
  source_security_group_id = aws_security_group.opensearch.id
}

resource "aws_security_group_rule" "opensearch_cluster_to_old_elasticsearch_cluster" {
  for_each = var.override_security_group_ids_for_green_cluster == null ? [] : toset(var.override_security_group_ids_for_green_cluster)

  description              = "OpenSearch cluster allows access to Old Elasticsearch cluster"
  type                     = "egress"
  from_port                = 9200
  to_port                  = 9200
  protocol                 = "tcp"
  security_group_id        = aws_security_group.opensearch.id
  source_security_group_id = each.value
}

resource "aws_security_group_rule" "old_elasticsearch_cluster_to_opensearch_cluster" {
  for_each = var.override_security_group_ids_for_green_cluster == null ? [] : toset(var.override_security_group_ids_for_green_cluster)

  description              = "Old Elasticsearch cluster allows access to OpenSearch cluster"
  type                     = "egress"
  from_port                = 9200
  to_port                  = 9200
  protocol                 = "tcp"
  security_group_id        = each.value
  source_security_group_id = aws_security_group.opensearch.id
}
