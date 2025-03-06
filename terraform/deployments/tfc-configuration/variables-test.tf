module "variable-set-ephemeral" {
  source = "./variable-set"

  name = "common-ephemeral"
  tfvars = {
    cluster_version               = "1.31"
    cluster_log_retention_in_days = 7

    vpc_cidr = "10.10.0.0/16"

    eks_control_plane_subnets = {
      a = { az = "eu-west-1a", cidr = "10.10.4.0/24" }
      b = { az = "eu-west-1b", cidr = "10.10.5.0/24" }
      c = { az = "eu-west-1c", cidr = "10.10.6.0/24" }
    }

    eks_public_subnets = {
      a = { az = "eu-west-1a", cidr = "10.10.1.0/24" }
      b = { az = "eu-west-1b", cidr = "10.10.2.0/24" }
      c = { az = "eu-west-1c", cidr = "10.10.3.0/24" }
    }

    eks_private_subnets = {
      a = { az = "eu-west-1a", cidr = "10.10.32.0/19" }
      b = { az = "eu-west-1b", cidr = "10.10.64.0/19" }
      c = { az = "eu-west-1c", cidr = "10.12.96.0/19" }
    }

    legacy_public_subnets = {}

    legacy_private_subnets = {}

    govuk_environment = "ephemeral"
  }
}
