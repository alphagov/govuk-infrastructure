locals {
  clamav_db_efs_name = "clamav-db-${local.cluster_name}"
}

resource "aws_efs_file_system" "clamav_db" {
  creation_token = local.clamav_db_efs_name
  tags = {
    "Name"        = local.clamav_db_efs_name
    "Description" = "EFS where ClamAV virus signature database is stored"
  }
}

resource "aws_security_group" "clamav_db" {
  name        = local.clamav_db_efs_name
  vpc_id      = data.terraform_remote_state.infra_vpc.outputs.vpc_id
  description = "Security group of ${local.clamav_db_efs_name} EFS"
}

resource "aws_security_group_rule" "clamav_db_from_eks_workers" {
  description              = "ClamAV DB EFS accepts requests from EKS nodes"
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.clamav_db.id
  source_security_group_id = data.terraform_remote_state.cluster_infrastructure.outputs.node_security_group_id
}

resource "aws_efs_mount_target" "clamav_db_mount_targets" {
  for_each        = toset(data.terraform_remote_state.infra_networking.outputs.private_subnet_ids)
  file_system_id  = aws_efs_file_system.clamav_db.id
  subnet_id       = each.key
  security_groups = [aws_security_group.clamav_db.id]
}

resource "aws_efs_access_point" "clamav_db" {
  file_system_id = aws_efs_file_system.clamav_db.id
  posix_user {
    uid = 1001
    gid = 1001
  }
  root_directory {
    path = "/clamav-db"
    creation_info {
      owner_uid   = 1001
      owner_gid   = 1001
      permissions = "0755"
    }
  }
}

resource "kubernetes_persistent_volume" "clamav_db_efs" {
  metadata {
    name   = "clamav-db-efs"
    labels = { "app.kubernetes.io/managed-by" = "Terraform" }
  }
  spec {
    storage_class_name = ""
    claim_ref {
      name      = "clamav-db-efs"
      namespace = "apps" # TODO: get this from TF remote state.
    }
    capacity     = { storage = "1Gi" }
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      nfs {
        server = aws_efs_file_system.clamav_db.dns_name
        path   = "/"
      }
    }
    mount_options = [
      "tls",
      "accesspoint=${aws_efs_access_point.clamav_db.id}",
    ]
  }
}
