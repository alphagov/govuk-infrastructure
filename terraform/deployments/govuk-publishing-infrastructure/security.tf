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
#
# Avoid "ingress"/"egress" in our own names: they are ambiguous with Kubernetes
# Ingress resources. Let the resource type and from_/to_ convey traffic direction.

data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

# Managed Prefix List for Fastly POPs
resource "aws_ec2_managed_prefix_list" "fastly" {
  name           = "fastly-cdn-ranges"
  address_family = "IPv4"
  max_entries    = 25

  dynamic "entry" {
    for_each = data.fastly_ip_ranges.fastly.cidr_blocks
    content {
      cidr        = entry.value
      description = "Fastly Edge POP"
    }
  }
}

# Managed Prefix List for Office IPs
resource "aws_ec2_managed_prefix_list" "office" {
  name           = "office-ips"
  address_family = "IPv4"
  max_entries    = 20

  dynamic "entry" {
    for_each = var.office_ips
    content {
      cidr        = entry.value
      description = "Office IPs"
    }
  }
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
# Origin ALBs (www-origin, assets-origin, bouncer, etc.)
#
# These ALBs are created by the AWS Load Balancer Controller from Kubernetes Ingress
# resources, and are the origins that Fastly and CloudFront fetch from.
#
# eks_ingress_www_origin is the legacy base SG attached to every origin ALB. It holds
# egress and is the SG trusted by the EKS nodes. Its name predates the naming guidance
# above and can't be changed in place (it is ForceNew and the SG is in use), so it is
# being replaced by origin_alb. Both stay attached until every ALB has
# the new SG; only then can eks_ingress_www_origin be detached and deleted.
#
# Each upstream source (CloudFront, Fastly, office) has its own origin_alb_from_* SG
# so that they can be managed independently and each stays within the per-SG rule
# quota (a rule referencing a prefix list counts the list's max_entries against the
# quota, once per rule).
#
# ALBs select these SGs via the alb.ingress.kubernetes.io/security-groups annotation
# in govuk-helm-charts. The controller matches that annotation against the SG's Name
# tag (not its group name), so Name tags must not be changed while SGs are in use.

locals {
  origin_alb_ports = { http = 80, https = 443 }
}

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

# TODO: Delete once the per-source SGs below are attached to all ALBs in govuk-helm-charts.
resource "aws_security_group_rule" "eks_ingress_www_origin_from_office_and_fastly_http" {
  description       = "EKS ingress www-origin accepts requests from office and Fastly"
  type              = "ingress"
  from_port         = 80
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = concat(var.office_ips, data.fastly_ip_ranges.fastly.cidr_blocks)
  security_group_id = aws_security_group.eks_ingress_www_origin.id

  lifecycle {
    ignore_changes = [cidr_blocks]
  }
}

# TODO: Delete once the per-source SGs below are attached to all ALBs in govuk-helm-charts.
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

# CloudFront

resource "aws_security_group" "origin_alb_from_cloudfront" {
  name        = "origin_alb_from_cloudfront"
  vpc_id      = data.tfe_outputs.vpc.nonsensitive_values.id
  description = "Allows CloudFront to reach origin ALBs."
  tags = {
    System = "Frontend"
    Name   = "origin_alb_from_cloudfront"
  }
}

resource "aws_vpc_security_group_ingress_rule" "origin_alb_from_cloudfront_https" {
  description       = "Origin ALBs accept HTTPS requests from CloudFront"
  security_group_id = aws_security_group.origin_alb_from_cloudfront.id
  prefix_list_id    = data.aws_ec2_managed_prefix_list.cloudfront.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

# Fastly

resource "aws_security_group" "origin_alb_from_fastly" {
  name        = "origin_alb_from_fastly"
  vpc_id      = data.tfe_outputs.vpc.nonsensitive_values.id
  description = "Allows Fastly POPs to reach origin ALBs."
  tags = {
    System = "Frontend"
    Name   = "origin_alb_from_fastly"
  }
}

resource "aws_vpc_security_group_ingress_rule" "origin_alb_from_fastly" {
  for_each          = local.origin_alb_ports
  description       = "Origin ALBs accept ${upper(each.key)} requests from Fastly"
  security_group_id = aws_security_group.origin_alb_from_fastly.id
  prefix_list_id    = aws_ec2_managed_prefix_list.fastly.id
  ip_protocol       = "tcp"
  from_port         = each.value
  to_port           = each.value
}

# Office

resource "aws_security_group" "origin_alb_from_office" {
  name        = "origin_alb_from_office"
  vpc_id      = data.tfe_outputs.vpc.nonsensitive_values.id
  description = "Allows office IPs to reach origin ALBs."
  tags = {
    System = "Frontend"
    Name   = "origin_alb_from_office"
  }
}

resource "aws_vpc_security_group_ingress_rule" "origin_alb_from_office" {
  for_each          = local.origin_alb_ports
  description       = "Origin ALBs accept ${upper(each.key)} requests from office IPs"
  security_group_id = aws_security_group.origin_alb_from_office.id
  prefix_list_id    = aws_ec2_managed_prefix_list.office.id
  ip_protocol       = "tcp"
  from_port         = each.value
  to_port           = each.value
}

# Base SG (EKS workers and NAT)
#
# Replaces eks_ingress_www_origin as the base SG: it holds the ALBs' only egress (to
# their targets), is the SG trusted by the EKS nodes, and admits in-cluster clients
# coming back in via the NAT gateways. Targets are pod IPs (target-type: ip) on the
# nginx sidecar port, which also serves the /readyz health checks.

locals {
  origin_alb_target_port = 8080
}

resource "aws_security_group" "origin_alb" {
  name        = "origin_alb"
  vpc_id      = data.tfe_outputs.vpc.nonsensitive_values.id
  description = "Base SG for origin ALBs: egress to EKS targets and HTTPS from EKS NAT gateways."
  tags = {
    System = "Frontend"
    Name   = "origin_alb"
  }
}

resource "aws_vpc_security_group_egress_rule" "origin_alb_to_eks_workers" {
  description                  = "Origin ALBs send requests to EKS workers"
  security_group_id            = aws_security_group.origin_alb.id
  referenced_security_group_id = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.node_security_group_id
  ip_protocol                  = "tcp"
  from_port                    = local.origin_alb_target_port
  to_port                      = local.origin_alb_target_port
}

resource "aws_vpc_security_group_ingress_rule" "eks_workers_from_origin_alb" {
  description                  = "EKS workers accept requests from origin ALBs"
  security_group_id            = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.node_security_group_id
  referenced_security_group_id = aws_security_group.origin_alb.id
  ip_protocol                  = "tcp"
  from_port                    = local.origin_alb_target_port
  to_port                      = local.origin_alb_target_port
}

resource "aws_vpc_security_group_ingress_rule" "origin_alb_from_eks_nat" {
  for_each          = toset(data.tfe_outputs.cluster_infrastructure.nonsensitive_values.public_nat_gateway_ips)
  description       = "Origin ALBs accept HTTPS requests from EKS NAT gateways"
  security_group_id = aws_security_group.origin_alb.id
  cidr_ipv4         = "${each.value}/32"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

# TODO: Delete these moved blocks once applied in all environments. The SGs are still
# replaced (name is ForceNew); moved only keeps the plan readable.

moved {
  from = aws_security_group.eks_ingress_www_origin_from_cloudfront
  to   = aws_security_group.origin_alb_from_cloudfront
}

moved {
  from = aws_vpc_security_group_ingress_rule.eks_ingress_www_origin_from_cloudfront_https
  to   = aws_vpc_security_group_ingress_rule.origin_alb_from_cloudfront_https
}

moved {
  from = aws_security_group.eks_ingress_www_origin_from_fastly
  to   = aws_security_group.origin_alb_from_fastly
}

moved {
  from = aws_vpc_security_group_ingress_rule.eks_ingress_www_origin_from_fastly
  to   = aws_vpc_security_group_ingress_rule.origin_alb_from_fastly
}

moved {
  from = aws_security_group.eks_ingress_www_origin_from_office
  to   = aws_security_group.origin_alb_from_office
}

moved {
  from = aws_vpc_security_group_ingress_rule.eks_ingress_www_origin_from_office
  to   = aws_vpc_security_group_ingress_rule.origin_alb_from_office
}
