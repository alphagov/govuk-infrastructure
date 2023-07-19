resource "aws_security_group_rule" "postgres_from_eks_workers" {
  description              = "Database accepts requests from EKS nodes"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = data.terraform_remote_state.infra_security_groups.outputs.sg_ckan_id
  source_security_group_id = data.terraform_remote_state.cluster_infrastructure.outputs.node_security_group_id
}

resource "aws_security_group_rule" "redis_from_eks_workers" {
  description              = "Redis accepts requests from EKS nodes"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = data.terraform_remote_state.infra_security_groups.outputs.sg_backend-redis_id
  source_security_group_id = data.terraform_remote_state.cluster_infrastructure.outputs.node_security_group_id
}
