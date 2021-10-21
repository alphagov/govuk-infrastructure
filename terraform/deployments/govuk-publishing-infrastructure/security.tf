# Security group rules
#
# Naming: please use the following conventions where appropriate:
# For ingress rules:
#   Name: {destination}_from_{source}_{protocol}
#   Description: {destination} accepts requests from {source} over {protocol}
# For egress rules:
#   Name: {source}_to_{destination}_{protocol}
#   Description: {source} sends requests to {destination} over {protocol}


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

resource "aws_security_group_rule" "shared_redis_cluster_from_any_tcp" {
  type              = "ingress"
  from_port         = var.shared_redis_cluster_port
  to_port           = var.shared_redis_cluster_port
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/8"] # TODO: investigate whether this needs to be tighten further
  security_group_id = aws_security_group.shared_redis_cluster.id
}
