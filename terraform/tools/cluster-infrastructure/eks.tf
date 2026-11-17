locals {
  cluster_services_namespace = "cluster-services"
  secrets_prefix             = "govuk" # pragma: allowlist secret
  monitoring_namespace       = "monitoring"

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

  default_cluster_addons = {
    coredns            = { addon_version = "v1.14.3-eksbuild.3", resolve_conflicts_on_create = "OVERWRITE" }
    kube-proxy         = { addon_version = "v1.35.3-eksbuild.13", resolve_conflicts_on_create = "OVERWRITE" }
    kube-state-metrics = { addon_version = "v2.19.1-eksbuild.1", resolve_conflicts_on_create = "OVERWRITE" }
    metrics-server     = { addon_version = "v0.8.1-eksbuild.11", resolve_conflicts_on_create = "OVERWRITE" }
    vpc-cni = {
      addon_version               = "v1.22.2-eksbuild.1",
      resolve_conflicts_on_create = "OVERWRITE",
      before_compute              = true
      configuration_values = jsonencode({
        enableNetworkPolicy = "true"
      })
    }
  }

  eks_pod_identity_addon = {
    eks-pod-identity-agent = { addon_version = "v1.3.10-eksbuild.2", resolve_conflicts_on_create = "OVERWRITE" }
  }


  # Uncomment to configure optional or per-env addons.
  enabled_cluster_addons = merge(
    local.default_cluster_addons,
    var.enable_eks_pod_identity_addon ? local.eks_pod_identity_addon : {},
  )

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


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.environment_name
  kubernetes_version = var.cluster_version
  subnet_ids         = [for s in data.tfe_outputs.networking.nonsensitive_values.control_plane_subnets : s]
  vpc_id             = data.tfe_outputs.networking.nonsensitive_values.id

  addons = local.enabled_cluster_addons

  endpoint_public_access                 = true
  cloudwatch_log_group_retention_in_days = var.cluster_log_retention_in_days
  enabled_log_types = [
    "api", "audit", "authenticator", "controllerManager", "scheduler"
  ]

  encryption_config = {
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }
  create_kms_key                = false
  kms_key_enable_default_policy = false

  # We're just using the cluster primary SG as created by EKS.
  create_security_group      = false
  create_node_security_group = false

  authentication_mode                      = var.authentication_mode
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = local.eks_managed_node_groups

  iam_role_additional_policies = {
    AmazonEKSVPCResourceController = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  }
}

resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key (${var.environment_name})"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}
