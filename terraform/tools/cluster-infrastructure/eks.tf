module "eks" {
  source = "./modules/eks"

  environment_name = var.environment_name
  cluster_version  = var.cluster_version
  vpc_config = {
    vpc_id                   = data.tfe_outputs.networking.nonsensitive_values.vpc_id
    control_plane_subnet_ids = data.tfe_outputs.networking.nonsensitive_values.eks_control_plane_subnet_ids
    node_private_subnet_ids  = data.tfe_outputs.networking.nonsensitive_values.private_subnet_ids
  }

  deletion_protection = false

  region = data.aws_region.current.name

  blue_node_group_config = {
    enabled        = true
    ami_type       = "AL2023_ARM_64_STANDARD"
    desired_size   = 2
    max_size       = 6
    min_size       = 1
    instance_types = ["m8g.large"]
    disk_size      = 60
  }

  green_node_group_config = {
    enabled        = false
    ami_type       = "AL2023_ARM_64_STANDARD"
    desired_size   = 2
    max_size       = 6
    min_size       = 1
    instance_types = ["m8g.large"]
    disk_size      = 60
  }
}


