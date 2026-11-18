locals {
  default_block_device_mappings = {
    xvda = {
      device_name = "/dev/xvda"
      ebs = {
        volume_size           = var.node_disk_size
        volume_type           = "gp3"
        encrypted             = true
        delete_on_termination = true
      }
    }
  }

  managed_node_group_defaults = {
    capacity_type                  = "ON_DEMAND"
    subnet_ids                     = [for s in data.tfe_outputs.networking.nonsensitive_values.private_subnets_ids : s]
    create_security_group          = false
    create_iam_role                = false
    iam_role_arn                   = aws_iam_role.node.arn
    enable_monitoring              = true
    enable_efa_only                = false
    use_latest_ami_release_version = false
    metadata_options = {
      http_put_response_hop_limit = 2
    }
  }

  arm_managed_node_group_blue = {
    arm_blue = merge(
      local.managed_node_group_defaults,
      {
        ami_type              = "AL2023_ARM_64_STANDARD"
        name_prefix           = "${var.environment_name}-blue"
        desired_size          = var.arm_workers_blue_size_desired
        max_size              = var.arm_workers_blue_size_max
        min_size              = var.arm_workers_blue_size_min
        instance_types        = var.arm_workers_blue_instance_types
        update_config         = { max_unavailable = 1 }
        block_device_mappings = local.default_block_device_mappings
        additional_tags = {
          "k8s.io/cluster-autoscaler/enabled"                 = "true"
          "k8s.io/cluster-autoscaler/${var.environment_name}" = "owned"
        }
      }
    )
  }

  # This will be a "Green" Node Group once Blue has become primary
  arm_managed_node_group_green = {
    arm_green = merge(
      local.managed_node_group_defaults,
      {
        ami_type              = "AL2023_ARM_64_STANDARD"
        name_prefix           = "${var.environment_name}-green"
        desired_size          = var.arm_workers_green_size_desired
        max_size              = var.arm_workers_green_size_max
        min_size              = var.arm_workers_green_size_min
        instance_types        = var.arm_workers_green_instance_types
        update_config         = { max_unavailable = 1 }
        block_device_mappings = local.default_block_device_mappings
        additional_tags = {
          "k8s.io/cluster-autoscaler/enabled"                 = "true"
          "k8s.io/cluster-autoscaler/${var.environment_name}" = "owned"
        }
      }
    )
  }


  eks_managed_node_groups = merge(var.enable_arm_workers_blue ? local.arm_managed_node_group_blue : {}, var.enable_arm_workers_green ? local.arm_managed_node_group_green : {})

}

resource "aws_eks_node_group" "workers" {
  for_each        = local.eks_managed_node_groups
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = each.key


  node_role_arn = aws_iam_role.example.arn
  subnet_ids    = aws_subnet.example[*].id

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}
