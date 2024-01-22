module "variable-set-integration" {
  source = "./variable-set"

  name = "common-integration"
  tfvars = {
    govuk_aws_state_bucket              = "govuk-terraform-steppingstone-integration"
    cluster_infrastructure_state_bucket = "govuk-terraform-integration"

    cluster_version               = 1.28
    cluster_log_retention_in_days = 7

    eks_control_plane_subnets = {
      a = { az = "eu-west-1a", cidr = "10.1.19.0/28" }
      b = { az = "eu-west-1b", cidr = "10.1.19.16/28" }
      c = { az = "eu-west-1c", cidr = "10.1.19.32/28" }
    }

    eks_licensify_gateways = {
      a = { az = "eu-west-1a", cidr = "10.1.20.0/24", eip = "eipalloc-089a8992b681613b0" }
      b = { az = "eu-west-1b", cidr = "10.1.21.0/24", eip = "eipalloc-0ab1a007f974bd7a9" }
      c = { az = "eu-west-1c", cidr = "10.1.22.0/24", eip = "eipalloc-079ae4b8dd0785851" }
    }

    eks_public_subnets = {
      a = { az = "eu-west-1a", cidr = "10.1.20.0/24" }
      b = { az = "eu-west-1b", cidr = "10.1.21.0/24" }
      c = { az = "eu-west-1c", cidr = "10.1.22.0/24" }
    }

    eks_private_subnets = {
      a = { az = "eu-west-1a", cidr = "10.1.24.0/22" }
      b = { az = "eu-west-1b", cidr = "10.1.28.0/22" }
      c = { az = "eu-west-1c", cidr = "10.1.32.0/22" }
    }

    govuk_environment = "integration"
    force_destroy     = true

    publishing_service_domain = "integration.publishing.service.gov.uk"

    frontend_memcached_node_type   = "cache.t4g.micro"
    shared_redis_cluster_node_type = "cache.m6g.large"

    # Non-production-only access is sufficient to access tools in this cluster.
    github_read_write_team = "alphagov:gov-uk"

    grafana_db_auto_pause       = true
    rds_apply_immediately       = true
    rds_backup_retention_period = 1
    rds_skip_final_snapshot     = true

    secrets_recovery_window_in_days = 0

    argo_redis_ha       = false
    desired_ha_replicas = 1

    ckan_s3_organogram_bucket = "datagovuk-integration-ckan-organogram"
  }
}
