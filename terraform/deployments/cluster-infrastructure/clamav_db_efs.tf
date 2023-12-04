# TODO: move this out of cluster-infrastructure; it doesn't belong.
locals {
  clamav_db_name = "clamav-db-${var.cluster_name}"
}

resource "aws_efs_file_system" "clamav-db" {
  creation_token = local.clamav_db_name
  tags = {
    Description = "EFS where Clamav virus signature database is stored"
  }
}

resource "aws_security_group" "clamav-db" {
  name        = local.clamav_db_name
  vpc_id      = data.terraform_remote_state.infra_vpc.outputs.vpc_id
  description = "Security group of ${local.clamav_db_name}"
}

resource "aws_security_group_rule" "clamav_db_from_eks_workers" {
  description              = "Clamav DB EFS accepts requests from EKS nodes"
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.clamav-db.id
  source_security_group_id = local.node_security_group_id
}

resource "aws_efs_mount_target" "clamav-db-mount-targets" {
  for_each        = toset(data.terraform_remote_state.infra_networking.outputs.private_subnet_ids)
  file_system_id  = aws_efs_file_system.clamav-db.id
  subnet_id       = each.key
  security_groups = [aws_security_group.clamav-db.id]
}
