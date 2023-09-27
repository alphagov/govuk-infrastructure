resource "aws_security_group" "rds" {
  name        = "ckan-rds-eks"
  description = "Allow access to CKAN DB from EKS nodes"
  vpc_id      = data.terraform_remote_state.infra_vpc.outputs.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "rds" {
  security_group_id = aws_security_group.rds.id

  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"

  referenced_security_group_id = data.terraform_remote_state.cluster_infrastructure.outputs.node_security_group_id
}
