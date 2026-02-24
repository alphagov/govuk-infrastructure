module "variable-set-ephemeral" {
  source = "./variable-set"

  name     = "common-ephemeral"
  priority = false
  tfvars = {
    cluster_version               = "1.33"
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
      c = { az = "eu-west-1c", cidr = "10.10.96.0/19" }
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
