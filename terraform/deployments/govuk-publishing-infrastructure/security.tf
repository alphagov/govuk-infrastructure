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
# Redis
#

resource "aws_security_group_rule" "shared_redis_cluster_to_any_any" {
  description       = "Redis cluster sends requests to anywhere over any protocol"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.shared_redis_cluster.id
}

resource "aws_security_group_rule" "shared_redis_cluster_from_any" {
  description       = "Shared Redis cluster for EKS accepts requests from EKS nodes"
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  security_group_id = aws_security_group.shared_redis_cluster.id
  # EKS creates *managed* nodes in the *cluster* SG, not the worker node SG. Go figure.
  source_security_group_id = data.terraform_remote_state.cluster_infrastructure.outputs.cluster_security_group_id
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
  source_security_group_id = data.terraform_remote_state.cluster_infrastructure.outputs.cluster_security_group_id
}

#
# Rules added to external security groups managed by govuk-aws
#

resource "aws_security_group_rule" "mongodb_from_eks_workers" {
  description              = "Shared MongoDB (DocumentDB) accepts requests from EKS nodes"
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  security_group_id        = data.terraform_remote_state.infra_security_groups.outputs.sg_mongo_id
  source_security_group_id = data.terraform_remote_state.cluster_infrastructure.outputs.cluster_security_group_id
}

resource "aws_security_group_rule" "router_mongodb_from_eks_workers" {
  description              = "Router MongoDB accepts requests from EKS nodes"
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  security_group_id        = data.terraform_remote_state.infra_security_groups.outputs.sg_router-backend_id
  source_security_group_id = data.terraform_remote_state.cluster_infrastructure.outputs.cluster_security_group_id
}

# TODO: Only the Postgresql instances created by govuk-aws/app-govuk-rds are
# open to traffic from EKS nodes. There are 2 other instances, content-data-api
# and transition, which are not covered since they are in a different terraform
# project and have not been migrated yet.
resource "aws_security_group_rule" "postgres_from_eks_workers" {
  for_each                 = data.terraform_remote_state.app_govuk_rds.outputs.sg_rds
  description              = "Database accepts requests from EKS nodes"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = each.value
  source_security_group_id = data.terraform_remote_state.cluster_infrastructure.outputs.cluster_security_group_id
}

resource "aws_security_group_rule" "mysql_from_eks_workers" {
  for_each                 = data.terraform_remote_state.app_govuk_rds.outputs.sg_rds
  description              = "Database accepts requests from EKS nodes"
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = each.value
  source_security_group_id = data.terraform_remote_state.cluster_infrastructure.outputs.cluster_security_group_id
}
