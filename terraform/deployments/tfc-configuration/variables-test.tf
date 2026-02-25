module "variable-set-ephemeral" {
  source = "./variable-set"

  name     = "common-ephemeral"
  priority = false
  tfvars = {
    cluster_version               = "1.33"
    cluster_log_retention_in_days = 7

    vpc_cidr = "10.10.0.0/16"

    eks_control_plane_subnets = {
      a = { az = "eu-west-1a", cidr = "10.10.19.0/28" }
      b = { az = "eu-west-1b", cidr = "10.10.19.16/28" }
      c = { az = "eu-west-1c", cidr = "10.10.19.32/28" }
    }

    eks_public_subnets = {
      a = { az = "eu-west-1a", cidr = "10.10.20.0/24" }
      b = { az = "eu-west-1b", cidr = "10.10.21.0/24" }
      c = { az = "eu-west-1c", cidr = "10.10.22.0/24" }
    }

    eks_private_subnets = {
      a = { az = "eu-west-1a", cidr = "10.10.24.0/22" }
      b = { az = "eu-west-1b", cidr = "10.10.28.0/22" }
      c = { az = "eu-west-1c", cidr = "10.10.32.0/22" }
    }

    legacy_private_subnets = {
      a = { az = "eu-west-1a", cidr = "10.10.4.0/24", nat = true }
      b = { az = "eu-west-1b", cidr = "10.10.5.0/24", nat = true }
      c = { az = "eu-west-1c", cidr = "10.10.6.0/24", nat = true }

      rds_a = { az = "eu-west-1a", cidr = "10.10.10.0/24", nat = false }
      rds_b = { az = "eu-west-1b", cidr = "10.10.11.0/24", nat = false }
      rds_c = { az = "eu-west-1c", cidr = "10.10.12.0/24", nat = false }

      elasticache_a = { az = "eu-west-1a", cidr = "10.10.7.0/24", nat = false }
      elasticache_b = { az = "eu-west-1b", cidr = "10.10.8.0/24", nat = false }
      elasticache_c = { az = "eu-west-1c", cidr = "10.10.9.0/24", nat = false }

      elasticsearch_a = { az = "eu-west-1a", cidr = "10.10.16.0/24", nat = false }
      elasticsearch_b = { az = "eu-west-1b", cidr = "10.10.17.0/24", nat = false }
      elasticsearch_c = { az = "eu-west-1c", cidr = "10.10.18.0/24", nat = false }
    }

    govuk_environment = "ephemeral"
  }
}
