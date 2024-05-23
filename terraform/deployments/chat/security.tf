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
# Redis
#

resource "aws_security_group_rule" "chat_redis_cluster_to_any_any" {
  description       = "Redis cluster sends requests to anywhere over any protocol"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.chat_redis_cluster.id
}

resource "aws_security_group_rule" "chat_redis_cluster_from_any" {
  description              = "Redis cluster accepts requests from EKS nodes"
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.chat_redis_cluster.id
  source_security_group_id = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.node_security_group_id
}
