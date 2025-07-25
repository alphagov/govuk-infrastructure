# Security group rules
#
# Naming: please use the following conventions where appropriate:
# For ingress rules:
#   Name: {destination}_from_{source}_{port_name}
#   Description: {destination} accepts requests from {source} on {port_name}
# For egress rules:
#   Name: {source}_to_{destination}_{port_name}
#   Description: {source} sends requests to {destination} on {port_name}
# Omit the port name if it's obvious from the context.

data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

#
# Frontend memcached
#

resource "aws_security_group_rule" "frontend_memcached_to_any_any" {
  description       = "Frontend memcached sends requests to anywhere over any protocol"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.frontend_memcached.id
}

resource "aws_security_group_rule" "frontend_memcached_from_eks_workers" {
  description              = "Frontend memcached accepts requests from EKS nodes"
  type                     = "ingress"
  from_port                = 11211
  to_port                  = 11211
  protocol                 = "tcp"
  security_group_id        = aws_security_group.frontend_memcached.id
  source_security_group_id = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.node_security_group_id
}

#
# Rules added to external security groups managed by govuk-aws
#

resource "aws_security_group_rule" "rabbitmq_from_eks_workers" {
  description              = "RabbitMQ accepts AMQP requests from EKS nodes"
  type                     = "ingress"
  from_port                = 5671 # AMQP 1.0
  to_port                  = 5672 # AMQP 0-9-1
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rabbitmq.id
  source_security_group_id = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.node_security_group_id
}

resource "aws_security_group_rule" "shared_docdb_from_eks_workers" {
  description              = "Shared DocumentDB accepts requests from EKS nodes"
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  security_group_id        = data.tfe_outputs.security.nonsensitive_values.govuk_shared_documentdb_access_sg_id
  source_security_group_id = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.node_security_group_id
}

resource "aws_security_group_rule" "licensify_docdb_from_eks_workers" {
  description              = "Licensify DocumentDB accepts requests from EKS nodes"
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  security_group_id        = data.tfe_outputs.security.nonsensitive_values.govuk_licensify-documentdb_access_sg_id
  source_security_group_id = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.node_security_group_id
}

# Remove once the content-data-api RDS instance has been migrated to govuk-infrastructure
resource "aws_security_group_rule" "postgres_from_eks_workers" {
  for_each                 = { "content_data_api" = data.tfe_outputs.security.nonsensitive_values.govuk_content-data-api-postgresql-primary_access_sg_id }
  description              = "Database accepts requests from EKS nodes"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = each.value
  source_security_group_id = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.node_security_group_id
}

resource "aws_security_group_rule" "elasticsearch_from_eks_workers" {
  description              = "ElasticSearch accepts requests from EKS nodes (for example Licence Finder queries ES directly)."
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = data.tfe_outputs.security.nonsensitive_values.govuk_elasticsearch6_access_sg_id
  source_security_group_id = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.node_security_group_id
}

resource "aws_security_group_rule" "efs_from_eks_workers" {
  description              = "Shared EFS (Elastic File System) accepts requests from EKS nodes"
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = data.tfe_outputs.security.nonsensitive_values.govuk_asset-master-efs_access_sg_id
  source_security_group_id = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.node_security_group_id
}

#
# EKS Ingress-managed ALBs
#

resource "aws_security_group" "eks_ingress_www_origin" {
  name        = "eks_ingress_www_origin"
  vpc_id      = data.tfe_outputs.vpc.nonsensitive_values.id
  description = "ALBs serving EKS www-origin ingress (and signon ALBs in non-prod environments)."
  tags = {
    System = "Frontend"
    Name   = "eks_ingress_www_origin"
  }
}

resource "aws_security_group_rule" "eks_ingress_www_origin_from_eks_nat" {
  description       = "EKS ingress www-origin accepts requests from EKS NAT gateways"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = formatlist("%s/32", data.tfe_outputs.cluster_infrastructure.nonsensitive_values.public_nat_gateway_ips)
  security_group_id = aws_security_group.eks_ingress_www_origin.id
}

resource "aws_security_group_rule" "eks_ingress_www_origin_from_office_and_fastly_http" {
  description       = "EKS ingress www-origin accepts requests from office and Fastly"
  type              = "ingress"
  from_port         = 80
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = concat(var.office_ips, data.fastly_ip_ranges.fastly.cidr_blocks)
  security_group_id = aws_security_group.eks_ingress_www_origin.id
}

resource "aws_security_group_rule" "eks_ingress_www_origin_from_cloudfront_https" {
  description       = "EKS ingress www-origin accepts requests from Cloudfront"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.cloudfront.id]
  security_group_id = aws_security_group.eks_ingress_www_origin.id
}

resource "aws_security_group_rule" "eks_ingress_www_origin_to_any_any" {
  description       = "EKS ingress www-origin sends requests to anywhere over any protocol"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_ingress_www_origin.id
}

resource "aws_security_group_rule" "eks_workers_from_eks_ingress_www_origin" {
  description = "EKS workers accepts requests from EKS ingress www-origin"
  type        = "ingress"
  # TODO: it might be possible to restrict that
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.node_security_group_id
  source_security_group_id = aws_security_group.eks_ingress_www_origin.id
}
